#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export PATH=$PATH:/snap/bin

sudo apt update -y

if ! dpkg -l | grep -qw snapd; then
    sudo apt install snapd -y
    echo "snapd instalado"
fi

if ! sudo snap list | grep -qw microk8s; then
    sudo snap install microk8s --classic --channel=1.26/stable
    echo "microk8s instalado"
fi

if ! groups $USER | grep &>/dev/null "\bmicrok8s\b"; then
    sudo usermod -a -G microk8s $USER
fi

for addon in dns dashboard storage ingress; do
    if ! microk8s status --wait-ready | grep -q "$addon: enabled"; then
        microk8s enable $addon
        echo "microk8s $addon instalado"
    fi
done

if ! sudo snap aliases | grep -qw "microk8s.kubectl"; then
    sudo snap alias microk8s.kubectl kubectl
fi

if ! microk8s status --wait-ready | grep -q "helm3: enabled"; then
    microk8s enable helm3
    echo "microk8s helm3 instalado"
fi

if ! kubectl get crd | grep -qw "certificates.cert-manager.io"; then
    kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml
fi

if ! kubectl get namespace | grep -qw "cert-manager"; then
    kubectl create namespace cert-manager
fi

if ! microk8s helm3 repo list | grep -qw "jetstack"; then
    microk8s helm3 repo add jetstack https://charts.jetstack.io
    microk8s helm3 repo update
fi

if ! microk8s helm3 list -n cert-manager | grep -qw "cert-manager"; then
    microk8s helm3 install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.6.1
fi

microk8s kubectl apply -f /cluster-issuer.yaml

if ! microk8s helm3 repo list | grep -qw 'rancher-latest'; then 
    microk8s helm3 repo add rancher-latest https://releases.rancher.com/server-charts/latest && microk8s helm3 repo update; 
fi

if ! kubectl get namespace | grep -qw 'cattle-system'; 
    then kubectl create namespace cattle-system; 
fi

if ! microk8s helm3 list -n cattle-system | grep -qw 'rancher'; then 
   microk8s helm3 install rancher rancher-latest/rancher --namespace cattle-system --set hostname=localhost
fi

sudo sysctl -w fs.inotify.max_user_watches=2099999999
sudo sysctl -w fs.inotify.max_user_instances=2099999999
sudo sysctl -w fs.inotify.max_queued_events=2099999999
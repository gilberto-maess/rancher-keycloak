#!/bin/bash

export DEBIAN_FRONTEND=noninteractive
export PATH=$PATH:/snap/bin

sudo apt update -y

if ! dpkg -l | grep -qw snapd; then
    sudo apt install snapd -y
    echo "snapd instalado"
fi

sudo systemctl stop unattended-upgrades

if ! sudo snap list | grep -qw microk8s; then
    sudo snap install microk8s --classic --channel=1.26/stable
    echo "microk8s instalado"
fi

if ! groups $USER | grep &>/dev/null "\bmicrok8s\b"; then
    sudo usermod -a -G microk8s $USER
fi

for addon in dns dashboard storage ingress; do
    if ! sudo microk8s status --wait-ready | grep -q "$addon: enabled"; then
        sudo microk8s enable $addon
        echo "microk8s $addon instalado"
    fi
done

if ! sudo snap aliases | grep -qw "microk8s.kubectl"; then
    sudo snap alias microk8s.kubectl kubectl
fi

if ! sudo microk8s status --wait-ready | grep -q "helm3: enabled"; then
    sudo microk8s enable helm3
    echo "microk8s helm3 instalado"
fi

if ! sudo kubectl get crd | grep -qw "certificates.cert-manager.io"; then
    sudo kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.6.1/cert-manager.crds.yaml
fi

if ! sudo kubectl get namespace | grep -qw "cert-manager"; then
    sudo kubectl create namespace cert-manager
fi

if ! sudo microk8s helm3 repo list | grep -qw "jetstack"; then
    sudo microk8s helm3 repo add jetstack https://charts.jetstack.io
    sudo microk8s helm3 repo update
fi

if ! sudo microk8s helm3 list -n cert-manager | grep -qw "cert-manager"; then
    sudo microk8s helm3 install cert-manager jetstack/cert-manager --namespace cert-manager --version v1.6.1
fi

echo "microk8s certmanager instalado"

sudo kubectl apply -f /tmp/cluster-issuer.yaml

if ! sudo microk8s helm3 repo list | grep -qw 'rancher-latest'; then 
    sudo microk8s helm3 repo add rancher-latest https://releases.rancher.com/server-charts/latest && microk8s helm3 repo update; 
fi

if ! sudo kubectl get namespace | grep -qw 'cattle-system'; then 
    sudo kubectl create namespace cattle-system; 
fi

if ! sudo microk8s helm3 list -n cattle-system | grep -qw 'rancher'; then 
    sudo microk8s helm3 install rancher rancher-latest/rancher --namespace cattle-system --set hostname=$RANCHER_SUBDOMAIN --set ingress.tls.source=letsEncrypt --set letsEncrypt.email=$LETSENCRYPT_EMAIL; 
fi

echo "rancher instalado"

# Instalação do NFS Server
if ! dpkg -l | grep -qw nfs-kernel-server; then 
    DEBIAN_FRONTEND=noninteractive sudo apt-get update && DEBIAN_FRONTEND=noninteractive sudo apt-get install -y nfs-kernel-server; 
fi

echo "NFS Server Instalado"

# Exportar o diretório /app/sso/themes para o NFS
if [ ! -d /ubuntu/app/sso/themes ]; then sudo mkdir -p /ubuntu/app/sso/themes; fi
if [ $(stat -c %U /ubuntu/app/sso/themes) != 'nobody' ]; then sudo chown nobody:nogroup /ubuntu/app/sso/themes; fi
if [ $(stat -c %a /ubuntu/app/sso/themes) != '777' ]; then sudo chmod 777 /ubuntu/app/sso/themes; fi
if ! grep -q '^/ubuntu/app/sso/themes ' /etc/exports; then echo '/ubuntu/app/sso/themes *(rw,sync,no_subtree_check,no_root_squash)' | sudo tee -a /etc/exports; fi

# Reiniciar nfs-kernel-server após configurar os diretórios
sudo systemctl restart nfs-kernel-server

# Configuração do UFW
if ! sudo ufw status | grep -q "ALLOW.*$IPV4_SERVER.*nfs"; then 
    yes | sudo ufw allow from $IPV4_SERVER to any port nfs &&  yes | sudo ufw reload; 
fi

echo "NFS Server configurado!"

if ! sudo microk8s helm repo list | grep -q '^bitnami'; then
    sudo microk8s helm repo add bitnami https://charts.bitnami.com/bitnami
    echo "Repo bitnami adicionado"
fi
sudo microk8s helm repo update

# Outras configurações
sudo sysctl -w fs.inotify.max_user_watches=2099999999
sudo sysctl -w fs.inotify.max_user_instances=2099999999
sudo sysctl -w fs.inotify.max_queued_events=2099999999

echo "Outras configurações aplicadas"

sudo chmod +r /var/snap/microk8s/current/credentials/client.config

sudo systemctl start unattended-upgrades
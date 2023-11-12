# Integração de Keycloak e Rancher: Ampliando a Segurança e Eficiência na Gestão de Identidades e Acesso

A integração do Keycloak como Identity Provider (IdP) com o Rancher oferece uma série de benefícios significativos para a gestão de acesso a aplicativos e serviços em ambientes de nuvem. Esta combinação permite que as organizações simplifiquem e reforcem suas operações de segurança e gerenciamento de identidade de forma robusta e eficiente.

Vehamos alguns benefícios:

#### Centralização de Autenticação e Autorização:
O Keycloak proporciona um ponto central de gestão de identidades, permitindo que as credenciais dos usuários sejam gerenciadas em um local único. Isso não só melhora a segurança ao reduzir a superfície de ataque, mas também simplifica o processo de login para os usuários, que podem usar as mesmas credenciais em diferentes serviços gerenciados pelo Rancher.

#### Suporte a Múltiplos Protocolos de Identidade:
Keycloak suporta uma variedade de protocolos de identidade, como SAML, OpenID Connect e OAuth 2.0, facilitando a integração com uma ampla gama de aplicativos e serviços. Isso é particularmente valioso em ambientes Rancher, que frequentemente necessitam integrar soluções heterogêneas em termos de autenticação.

#### Gestão de Acesso Fino:
Com o Keycloak, administradores podem definir políticas de acesso granulares, controlando quem tem acesso a quais recursos dentro do Rancher. Isso é fundamental para manter a segurança em ambientes com muitos usuários e recursos, permitindo que apenas usuários autorizados tenham acesso a funções e dados críticos.

#### Autenticação Multifator (MFA):
A segurança é ainda mais reforçada pelo suporte do Keycloak à autenticação multifator. O MFA é essencial para proteger contra acessos não autorizados, e sua implementação através do Keycloak é tanto direta quanto eficiente, sem a necessidade de complexas customizações ou plugins adicionais.

#### Integração de Sistemas Externos e Federados:
Keycloak permite a integração com sistemas de identidade externos e federados, facilitando a extensão do controle de acesso para além dos limites tradicionais da empresa. Isso é especialmente útil para organizações que operam em múltiplas nuvens ou que requerem acesso interorganizacional.

#### Customização e Extensibilidade:
O Keycloak é altamente customizável e extensível, possibilitando a adaptação às necessidades específicas da organização. Isso significa que, à medida que as exigências de segurança e negócios evoluem, o Keycloak pode ser ajustado para atender a essas demandas sem comprometer a usabilidade ou a funcionalidade do Rancher.

#### Melhor Experiência do Usuário:
Ao oferecer um serviço de Single Sign-On (SSO), o Keycloak melhora significativamente a experiência do usuário ao interagir com o Rancher. Menos interrupções para a gestão de múltiplas senhas ou processos de login redundantes se traduzem em maior produtividade e satisfação do usuário.

#### Conformidade e Relatórios:
O Keycloak facilita o atendimento a requisitos de conformidade, como GDPR, HIPAA, entre outros, fornecendo recursos robustos para auditoria e relatórios de atividades de acesso. No contexto do Rancher, isso significa que os administradores podem gerar registros detalhados para análises de segurança e auditorias de conformidade.

Em resumo, a utilização do Keycloak como IdP com o Rancher apresenta uma abordagem poderosa para gestão de identidade e acesso, aprimorando a segurança, a conformidade e a eficiência operacional.

## Vamos Praticar

Para este artigo utilizaremos as seguintes tencnologias:
- Rancher: transforma a complexidade do gerenciamento de Kubernetes em simplicidade, permitindo o controle centralizado de clusters em qualquer infraestrutura
- Keycloak: sistema de gestão de identidades que facilita autenticação, autorização e administração de usuários com suporte para SSO e MFA
- Microk8s: solução Kubernetes leve e fácil de instalar que se adapta perfeitamente a ambientes de IoT, laboratórios de desenvolvimento e produção em pequena escala
- Azure Cloud: criaremos uma máquina virtual que será utilizada para provisionar o nosso cluster k8s.
- Terraform: para administrar a nossa infraestrutura como código.

Faça o clone do repositório https://github.com/gilberto-maess/rancher-keycloak.git.

### 1) Criação de conta de serviço na Azure

> Como pré-requisito, precisaremos instalar o az cli pelo link https://learn.microsoft.com/pt-br/cli/azure/install-azure-cli.

Após instalado o `az cli`, vamos nos atenticar e criar uma `entidade de serviço` no Azure Active Directory.

```
az login

az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/{subscription_id}" --name "https://maess.com.br/rancher-keycloak"
```

Aqui está o que cada parte do comando significa:

`az login`: comando utilizado para fazer login em sua conta da azure.

`az ad sp create-for-rbac`: criar uma entidade de serviço no Azure Active Directory (AD). Uma entidade de serviço é um tipo de identidade de segurança que é usada para aplicativos, serviços e ferramentas de automação que precisam acessar ou modificar recursos do Azure.

Aqui está o que cada parte do comando significa:

--role="Contributor": Isso atribui à entidade de serviço a função de "Contributor", o que significa que ela pode criar e gerenciar todos os recursos da assinatura do Azure, mas não pode conceder acesso a outros.

--scopes="/subscriptions/{subscription_id}": Isso define o escopo da autoridade da entidade de serviço a uma assinatura específica do Azure. O ID fornecido é um exemplo de um ID de assinatura do Azure.

--name "https://maess.com.br/rancher-keycloak": Este é o nome que você está atribuindo à entidade de serviço. Usar um URL é uma prática comum para nomear entidades de serviço; isso não precisa ser um URL ativo, apenas uma identificação única dentro do diretório do Azure AD.

--{subscription_id}: é o id da sua assinatura da Microsoft Azure.

Colete as seguintes informações ao executar o comando `az ad sp create-for-rbac`:
- client_id
- client_secret
- tenant_id
- subscription_id


### 2) Provisionamento da VM

Como foi dito anteriormente, o `Terraform` provisiona toda a nossa infraestrutura de cloud via código. Existem muitos benefícios dessa tecnologia como:
- gerenciamento da infra estrutura de maneira declarativa
- estado da infraestrutura represetado como código.
- automação e orquestração
- independência de provedor
- modularidade
- gestão de estado
- integração com ferramentas de CI/CD
- planos de ação: o terraform mostra as mudanças do que acontecerão se o código for aplicado
- idempotência
- segurança e conformidade.

Para saber mais, acesse o link https://developer.hashicorp.com/terraform?product_intent=terraform. Nada melhor do que a documentação da própria fonte!

#### 2.1) Configuração das Variáveis:

Você deverá criar um arquivo chamado `secrets.tfvars` com base no arquivo `secrets.tfvars.example` para poder aplicar as variáveis coletadas após a execução do comando `az ad sp create-for-rbac`.

O arquivo `secrets.tfvars` contém os segredos que utilizaremos em conjunto com o terraform para provisionar os nossos recursos na cloud da Azure.

#### Importante!

Altere as variáveis do arquivo varibles.tf:
- azure_dominio: o domínio que você utilizará para testar a sua aplicação.
- letsEncrypt_email: e-mail válido para que o Lets Encrypt possa enviar notificações de certificados ou informações importantes sobre seu serviço.
- meu_ip: seu ip público

> As variáveis acima precisam ser alteradas para que a aplicação funcione!

#### 2.2) Configuraçao do Cluster Issuer

Um ClusterIssuer no Kubernetes (K8s) é um recurso usado em conjunto com o Kubernetes Cert-Manager, que é uma ferramenta que facilita a automação da emissão e renovação de certificados SSL/TLS, incluindo aqueles fornecidos pelo Let's Encrypt. O ClusterIssuer é um objeto personalizado do Kubernetes que desempenha um papel importante na configuração e gerenciamento desses certificados.

Acesse o arquivo 1-provisionamento-da-vm/configs/cluster-issuer.yaml e altere o valor email para o mesmo e-mail configurado na varável letsEncrypt_email em seu arquivo variables.tf

#### 3.3) Levantando a Máquina

Realizadas todas as configurações, execute os comandos abaixo no diretório 1-provisionamento-da-vm para checar o plano de execução:

```
terraform init

terraform plan -var-file=secrets.tfvars
```

[imagem aqui]




















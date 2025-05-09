###### ESSA VERSÃO DO JENKINS EM UM AKS ESTÁ EM TESTES, NÃO ESTÁ FUNCIONANDO 100%, ESTOU RESOLVENDO AINDA POIS NA HORA DE EXECUTAR COMANDOS DOCKER NA PIPELINE, A PIPELINE QUEBRA, E É NECESSÁRIO HABILITAR UM AGENTE DO DOCKER QUE ESTOU ESTUDANDO AINDA

### Instalação do Jenkins via helm no AKS

#### Jenkins

###### SEQUENCIA DE DEPLOY, ceritifique-se que esteja no diretório dos arquivos .yaml 
```bash 
helm install jenkins jenkins/jenkins -n jenkins -f jenkins-values-ingress.yaml
kubectl apply -f jenkins-rbac.yaml
kubectl get svc -n jenkins
```
### Build
- É necessário realizar um build de uma imagem que tenha o docker instalado, para que o jenkins consiga executar comandos docker na pipeline, o arquivo dockerfile está no diretório JENKINS-CI-CD/jenkins/ci-cd/deploy-jenkins


1. Adicionar o repositório Helm do Jenkins

```bash
helm repo add jenkins https://charts.jenkins.io
helm repo update
```

2. Criar um namespace para o Jenkins (opcional, mas recomendado)

```bash
kubectl create namespace jenkins
```

3. Criar um arquivo jenkins-values.yaml (jenkins com loadbalancer)
```bash
controller:
  admin:
    username: admin
    password: admin123

  serviceType: LoadBalancer

  installPlugins:
    - kubernetes
    - workflow-aggregator
    - git
    - configuration-as-code
    - credentials-binding
    - blueocean
    - azure-credentials
    - azure-vm-agents
    - azure-container-agents

  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "1"
      memory: "2Gi"

  persistence:
    enabled: true
    size: 8Gi
    storageClass: default
    #storageClass: jenkins-sc

rbac:
  create: true
```

3.1 - Jenkins com ingress, Instalando o ingress
# Adicionar repositorio oficial do ingress nginx
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo add stable https://charts.helm.sh/stable/
helm repo update

# Verificar o IP Do loadbalancer criado pelo helm: 
kubectl get svc -A


# Criar ip público do LoadBalancer e coloca-lo no mesmo grupo de recursos do AKS
ip=74.163.168.68

# Usar Helm para fazer deploy do  NGINX ingress controller
helm install ingress-nginx ingress-nginx/ingress-nginx \
    --namespace $ns \
    --set controller.replicaCount=1 \
    --set controller.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set defaultBackend.nodeSelector."beta\.kubernetes\.io/os"=linux \
    --set controller.service.externalTrafficPolicy=Local \
    --set controller.service.loadBalancerIP="$ip" 

# Yaml do jenkins com ingress

```bash
controller:
  admin:
    username: admin
    password: admin123

  serviceType: ClusterIP

  installPlugins:
    - kubernetes
    - workflow-aggregator
    - git
    - configuration-as-code
    - credentials-binding
    - blueocean
    - azure-credentials
    - azure-vm-agents
    - azure-container-agents

  ingress:
    enabled: true
    apiVersion: networking.k8s.io/v1
    #hostName: dominio.com.br  
    hostName: jenkins.ADICIONE-O-IP-DO-INGRESS-AQUI.nip.io  
    annotations:
      nginx.ingress.kubernetes.io/ssl-redirect: "false"
    ingressClassName: nginx
    rules:
      #- host: dominio.com.br
      - host: jenkins.ADICIONE-O-IP-DO-INGRESS-AQUI.nip.io  
        http:
          paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: jenkins
                  port:
                    number: 8080  
  
  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "1"
      memory: "2Gi"

  persistence:
    enabled: true
    size: 8Gi
    storageClass: default

rbac:
  create: true

```
3.2 - Acessando o jenkins com ingress

```bash
# COM IP
http://jenkins.IP-DO-INGRESS.nip.io/

# COM DOMINIO
http://jenkins-test.com.br

```

3.3 - Jenkins com TLS, certificado no dominío

Crie uma secret para o certificado

```bash 
kubectl create secret tls jenkins-tls-secret \
  --cert=/path/to/tls.crt \
  --key=/path/to/tls.key \
  -n jenkins
```

3.4 - Yaml do jenkins utilizando TLS

```bash
controller:
  admin:
    username: admin
    password: admin123

  serviceType: ClusterIP

  installPlugins:
    - kubernetes
    - workflow-aggregator
    - git
    - configuration-as-code
    - credentials-binding
    - blueocean
    - azure-credentials
    - azure-vm-agents
    - azure-container-agents

  ingress:
    enabled: true
    apiVersion: networking.k8s.io/v1
    #hostName: dominio.com.br  
    hostName: jenkins.ADICIONE-O-IP-DO-INGRESS-AQUI.nip.io  
    annotations:
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    ingressClassName: nginx
    rules:
      #- host: jenkins.dominio.com.br
      - host: jenkins.ADICIONE-O-IP-DO-INGRESS-AQUI.nip.io 
        http:
          paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: jenkins
                  port:
                    number: 8080
    tls:
      - hosts:
         # - jenkins.dominio.com.br
          - jenkins.ADICIONE-O-IP-DO-INGRESS-AQUI.nip.io 
        secretName: jenkins-tls-secret  # Nome do Secret TLS criado acima

  resources:
    requests:
      cpu: "500m"
      memory: "1Gi"
    limits:
      cpu: "1"
      memory: "2Gi"

  persistence:
    enabled: true
    size: 8Gi
    storageClass: default

rbac:
  create: true
```

4. Instalar o Jenkins com Helm

```bash
helm install jenkins jenkins/jenkins -n jenkins -f jenkins-values-ingress.yaml
```

5. Acessar o Jenkins

```bash
kubectl get svc -n jenkins
```

6. Dar permissões para o Jenkins no AKS (RBAC), Crie um ServiceAccount e as permissões para que Jenkins consiga aplicar manifestos e interagir com o cluster

```bash
# jenkins-rbac.yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: jenkins
  namespace: jenkins
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: jenkins
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
subjects:
- kind: ServiceAccount
  name: jenkins
  namespace: jenkins
```
6.1 Aplicar o RBAC para o funcionamento do Jenkins com o AKS
```bash
kubectl apply -f jenkins-rbac.yaml 
```



7. Configurar o Kubernetes plugin dentro do Jenkins
# Depois de acessar o painel do Jenkins:
- Vá em: Manage Jenkins > Manage Plugins
- Verifique se o plugin “Kubernetes” está instalado.
- Vá em: Manage Jenkins > Configure Clouds
- Adicione uma nova cloud “Kubernetes”.
- Use o ServiceAccount Token e a URL do cluster (ou deixe em branco para autodetectar).

8. (Recomendado para produção) - Criar um storageClass para armazenar dados do jenkins, como histório de builds, deploys, configurações feitas pela interface do jenkins. Essa storageClass irá utilizar um SSD, HD

```bash
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: jenkins-sc
provisioner: disk.csi.azure.com # <-- Modificar o disco caso seja necessário
parameters:
  skuname: Premium_LRS # <-- Modificar caso seja necessário, como standart, ultra etc..
reclaimPolicy: Retain
volumeBindingMode: WaitForFirstConsumer
allowVolumeExpansion: true
```

8.1 ( recomendado para produção) - Yaml definido para ambiente de produção, porém ainda não testado.

```bash
# =============== PRODUÇÃO ===============
controller:
  admin:
    existingSecret: jenkins-admin-secret  # Secret criado fora do YAML

  serviceType: ClusterIP

  installPlugins:
    - kubernetes
    - workflow-aggregator
    - git
    - configuration-as-code
    - credentials-binding
    - blueocean
    - azure-credentials
    - azure-vm-agents
    - azure-container-agents

  ingress:
    enabled: true
    apiVersion: networking.k8s.io/v1
    ingressClassName: nginx
    hostName: jenkins.seudominio.com.br  # Substitua pelo seu domínio real
    annotations:
      nginx.ingress.kubernetes.io/ssl-redirect: "true"
      nginx.ingress.kubernetes.io/proxy-body-size: "20m"
    tls:
      - hosts:
          - jenkins.seudominio.com.br
        secretName: jenkins-tls 
    rules:
      - host: jenkins.seudominio.com.br
        http:
          paths:
            - path: /
              pathType: Prefix
              backend:
                service:
                  name: jenkins
                  port:
                    number: 8080

  resources:
    requests:
      cpu: "2"
      memory: "4Gi"
    limits:
      cpu: "4"
      memory: "8Gi"

  persistence:
    enabled: true
    size: 50Gi
    storageClass: default  # Ou um storage com snapshot habilitado, se tiver

rbac:
  create: true

```
8.2 (Recomendado para Produção) - Criar uma senha para acessar o Jenkins

```bash
kubectl create secret generic jenkins-admin-secret \
  --from-literal=jenkins-admin-user=[SEU-USUARIO] \
  --from-literal=jenkins-admin-password=[SUA-SENHA] \
  -n jenkins
```
#=============== PRODUÇÃO ===============

9. Instalando Pluguins, vá em: Gerenciar Jenkins > Plugins > Extensões disponíveis
- Em Extensões disponíveis, pesquise por: Docker, Docker pipeline, Kubernetes CLI; Esses plugins vai ser necessário para que o jenkins consiga executar comandos docker e Kubernetes 



#================================= COMO USAR EM AMBIENTE DE TESTES - NÃO SEGURO ===============================

1. Vá em: Painel de controle > Nova tarefa 
- Selecione a Pipelie, adicione um nome, clique em "Tudo certo"
- Aguarde a criação do template
- Modifique o template de acordo com a sua preferência, aqui eu deixei tudo padrão
- Depois do template criado, em definição, selecione "Pipeline script from SCM" 
- SCM, escolha "Git"
- Coloque A URL do repositório
- Credencial; .............................
- Defina a Branch que vai ser utilizada
- Adicione o caminho do script "Jenkinsfile" no github, exemplo: azure-estudos/JENKINS-CI-CD/jenkins/ci-cd
/jenkinsfile

2. Logar no acr de forma -----INSEGURA------

- Acesse o portal do Azure.
- Vá até seu Container Registry (jenkinshub).
- No menu lateral, vá em Access keys.
-Ative a opção Admin user.

- Você verá:
Username
Password e Password2

3. Como usar no Jenkins:
- No Jenkins, vá em Manage Jenkins > Credentials > Global > Add Credentials.
- Tipo: Username with password
- Username: o nome mostrado no Azure.
- Password: a senha (Password ou Password2)
- ID: por exemplo acr-admin-user

Jenkinsfile com admin user:

```bash
docker.withRegistry("https://jenkinshub.azurecr.io", "acr-admin-user") {
    dockerImage.push()
}
```

#================================= COMO USAR EM AMBIENTE DE PRODUÇÃO - SEGURO ===============================
1. Crie o SP com permissão para usar o ACR
```bash
# Descobre o ID do ACR
ACR_ID=$(az acr show --name jenkinshub --query id --output tsv)

# Cria o Service Principal com permissão para fazer push/pull
az ad sp create-for-rbac \
  --name jenkins-acr-sp \
  --role acrpush \
  --scopes $ACR_ID
```
- Esse comando retorna algo assim: (Guarde bem o appId e o password, vai usar eles no Jenkins.)
```bash
{
  "appId": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx",
  "displayName": "jenkins-acr-sp",
  "password": "xxxxxxxxxxxxxxxxxxxxxxxxxxxx",
  "tenant": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
}
```
2. Adicione no Jenkins
- Vá em: Manage Jenkins > Credentials > Global > Add Credentials.
- Tipo: Username with password
- Username: o appId
- Password: o password
- ID: acr-serviceprincipal (ou qualquer nome que você quiser usar no pipelin

3. Jenkinsfile com docker push autenticado no ACR
```bash
pipeline {
    agent any

    environment {
        ACR = 'jenkinshub.azurecr.io'
        IMAGE_NAME = 'conversao'
        TAG = "${env.BUILD_ID}"
    }

    stages {
        stage('Build docker image') {
            steps {
                script {
                    dockerImage = docker.build("${env.ACR}/${env.IMAGE_NAME}:${env.TAG}", "-f JENKINS-CI-CD/jenkins/src/Dockerfile .")
                }
            }
        }

        stage('Push docker image') {
            steps {
                script {
                    docker.withRegistry("https://${env.ACR}", "acr-serviceprincipal") {
                        dockerImage.push()
                    }
                }
            }
        }
    }
}

```

3. Desinstalando o Jenkins
```bash
helm list --namespace jenkins
helm uninstall jenkins --namespace jenkins
helm list --namespace jenkins
kubectl delete namespace jenkins
helm repo remove jenkins
```

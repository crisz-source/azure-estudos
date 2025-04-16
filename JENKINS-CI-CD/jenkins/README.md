### Instalação do Jenkins via helm no AKS

#### Jenkins

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


3.1 - Jenkins com ingress
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
                    number: 8080  # A porta do serviço do Jenkins
  
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
helm install jenkins jenkins/jenkins -n jenkins -f jenkins-values.yaml
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
      # cert-manager.io/cluster-issuer: "letsencrypt-prod" <- REMOVIDO
    tls:
      - hosts:
          - jenkins.seudominio.com.br
        secretName: jenkins-tls  # <- Esse Secret deve ser criado manualmente
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

#=============== PRODUÇÃO ===============
```
8.2 (Recomendado para Produção) - Criar uma senha para acessar o Jenkins

```bash
kubectl create secret generic jenkins-admin-secret \
  --from-literal=jenkins-admin-user=[SEU-USUARIO] \
  --from-literal=jenkins-admin-password=[SUA-SENHA] \
  -n jenkins
```











    ```
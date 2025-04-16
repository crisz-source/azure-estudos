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
















#### Jenkins

Para instalar o Jenkins, siga os passos abaixo:

1. Adicione a chave do Jenkins ao seu sistema:

    ```bash
    sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
      https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key
    ```

2. Adicione o repositório do Jenkins à lista de fontes do apt:

    ```bash
    echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] https://pkg.jenkins.io/debian-stable binary/" | sudo tee /etc/apt/sources.list.d/jenkins.list > /dev/null
    ```

3. Atualize a lista de pacotes e instale o Jenkins:

    ```bash
    sudo apt-get update && sudo apt-get install -y jenkins
    ```

#### Chave de Segurança

Para obter a senha inicial de administrador do Jenkins, execute o comando:

```bash
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```

#### Docker

Para instalar o Docker, siga os passos abaixo:

1. Adicione a chave GPG oficial do Docker:

    ```bash
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    sudo install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    ```

2. Adicione o repositório Docker às fontes do apt:

    ```bash
    echo \
      "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
      $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
      sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
    sudo apt-get update
    ```

3. Instale o Docker e seus componentes:

    ```bash
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
    ```

4. Adicione o usuário atual e o usuário Jenkins ao grupo docker:

    ```bash
    sudo usermod -aG docker $USER
    sudo usermod -aG docker jenkins
    ```

5. Reinicie o Jenkins para aplicar as permissões no Docker:

    ```bash
    sudo systemctl restart jenkins
    ```

#### Kubectl

Para instalar o kubectl, siga os passos abaixo:

1. Adicione as chaves e repositórios necessários:

    ```bash
    sudo apt-get update
    sudo apt-get install -y apt-transport-https ca-certificates curl gnupg

    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    sudo chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    ```

2. Adicione o repositório do Kubernetes:

    ```bash
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list
    sudo chmod 644 /etc/apt/sources.list.d/kubernetes.list
    ```

3. Atualize a lista de pacotes e instale o kubectl:

    ```bash
    sudo apt-get update
    sudo apt-get install -y kubectl
    ```
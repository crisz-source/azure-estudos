# Criando um AKS
1) - Pesquise por Azure Kubernetes Service
2) - Clique em criar
3) - Configure o AKS da forma que desejar

3.1) - Escolha seu grupo de recruso ou crie um novo
3.2) - Detalhes do Cluster, selecione um ambiente que faça sentido para a sua aplicação
3.3) - Defina um nome para o Cluster
3.4) - Defina a Região para o Cluste
3.5) - Selecione a zona de disponibilidade se preferir
3.6) - Selecione a versão do Kubernetes, recomendado deixar o default
3.7) - Atualização automática, habilitado o padrão
3.7.1) - Agendador de atualização automática, defina o melhor dia de backup para o cluster
3.8) - Tipo de canal de segurança do nó, imagem de nó padrão
3.8.1) - Agendador de canal de segurança, defina o melhor dia de atualização de segurança para os nodes
3.9) - Autenticação e Autorizaçã, Contas Locais com Kubernetes RBAC (esse não sei pra que serve)

# Adicionando um Quickstart Application do AKS
1) - No serviço AKS, clique em criar e clique na opção de quick start
2) - Selecione a primeira opção, Criar um aplicativo báscio para web
3) - Clique em avançar, verifique o YAML e depois clique em deploy
4) - Depois que o deploy for feito, clique em "Exibir o aplicativo", na primeira vez pode demorar um pouco


# Adicionando um YAML Application do AKS
1) - No serviço AKS, clique em criar e clique na opção de Aplication YAML
2) - Adicione esses dois yaml, de deploy e service:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  name: site
spec:
  replicas: 1
  selector:
    matchLabels:
      app: site
  template:
    metadata:
      labels:
        app: site
    spec:
      nodeSelector:
        "kubernetes.io/os": linux
      containers:
      - name: site
        image: higorluisbarbosa/site-treinamentos:v3
        resources:
          requests:
            cpu: 100m
            memory: 128Mi
          limits:
            cpu: 250m
            memory: 256Mi
        ports:
        - containerPort: 80

---
apiVersion: v1
kind: Service
metadata:
  name: site
spec:
  type: LoadBalancer
  ports:
  - port: 80
  selector:
    app: site
```
3) - Verifique nos Workloads se o pod foi criado corretamente, com um nome de "site" e o serviço como um nome de "site"



# Azure NodePool's
1) - Durante a criação de um cluster kubernetes utilizando o AKS, existe uma aba chamada Pools de nós 
2) - Note que já existe um pool de nós criado por padrão chamado "agentpool", e modo dele é "System", esse modo especifica que este pool de nós é o responsável de manter as configurações, a infraestrutura do kubernetes AKS funcionando corretamente.
3) - Clique em "Adicionar pool de nós" 
4) - Preencha as informações como, nome do pools de nós, escolha usuário, o modo usuário, linux
5) - Escolha o tamanho ideal para a sua aplicação
6) - Defina a quantidade minima de nós que será criado
7) - Defina a contagem máxima que eu um nó pool de nós pode ter, (Recomendado: 3 ou 4 nós)
8) - Defina o máximo de pod por container na estrutura de um arquivo.yaml
9) - Clique em adicionar se não tiver nenhum rótulo a ser acrescentado. 


# Conta de Armazenamento
1) - Na barra de pesquisa do portal Azure, pesquise por "Contas de armazenamento"
2) - Clique em criar
3) - Preencha as inforamções necessárias
4) - No campo "Serviço primário", escolha a melhor opção de acordo com o ambiente. Compartilhamento de arquivos, File Share Azure é a melhor opção, NFS e afins, Azure blob e Azure Data Lake Storage Gen 2 é a melhor opção
5) - Em "Avançado" Caso queira NFS V3, marque a opção "Habilitar namespace hierárquico" e depois "Habilitar o sistema de arquivos de rede v3"
6) - Em "Rede" Habilite o acesso público ou desabilite dependendo do cenário. A conta de armazenamento deve usar a mesma VNET do AKS, comumente chamada "aks-vnet-XXXX" e "aks-subnet (XXXXX)". Se tiver marcado a opção de acesso ao ip público, deverá acrescentar um IP
7) - Examniar + Criar
8) - Depois criado, abra a conta de armazenamento e crie um File share ou container dependendo do cenário de sua aplicação. Se for um cenário que utiliza NFS, container seria uma boa opção pois nele existe uma configuração de ACL(Access Control List). Caso a sua aplicação não necessite de NFS, poderá criar um file share normalmente.

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


# Azure Active Directory (AAD)
1) - Pesquise por Active Directory
2) - Para criar usuários, vá em Users
3) - Preencha as informações, nome e sobrenome, senha etc...
4) - Para criar os Grupos, vá em Groups
5) - Preencha as informaçõs necessárias para criar um grupo
6) - é possível acrescentar os usuários criados a um grupo especifico
6.1) - Entre no grupo criado, clique em "Members" no menu lateral esquerdo e clique em "Add members" procure pelo membro que deseja adicionar ao grupo
7) - É necessário adicionar à assinatura os grupos criados
7.1) - Vá na sua assinatura e clique em "IAM"
7.2) - Clique em "Add" 
7.3) - Escolha a permissão que deseja concender ao grupo criado 
7.4) - No campo "Members" da página "Add rola assignment" clique em "Select members" e seleciona o grupo que deseja adicionar ao IAM 
7.5) - Revisar e criar
8) - Pode-se criar um AKS integrado ao AAD criado
8.1) - Crie um AKS normalmente, na parte de "access" (por padrão o AAD e o RBAC já vem na criação do AKS até o ano de 2025), marque a opção de habilitar o AAD no AKS, clique no campo para adicionar um grupo ao AAD e selecione o grupo  que deseja.
9) - Para testar as permissões, basta acessar a conta criada anteriormente nos passos 1 ao 3.

# Ingress Controller com Http Routing (DESENVOLVIMENTO e TESTES)
1) - O ingress está no diretório chamado "ingress-appRouting "
2) - Habilite o http routing:  az aks enable-addons -g myGroupResources -n myAksName --addons http_application_routing (recomendado apenas para ambientes de Dev e Homologação)
3) - Adicione o host no ingress, o comando a seguir é possível pegar o host: *az aks show -n myAksName -g myGroupResources --query addonProfiles.httpApplicationRouting.config.HTTPApplicationRoutingZoneName*
4) - Dê um apply no arquivo app.yaml que está no diretório ingress-appRouting 

# Ingress Controller com NGINX
1) - Siga os pasasos de instalação do ingress NGINX no arquivo *nginx-cli.azcli* no diretório ingress
2) - Quando instalado pelo helm o ingress controller nginx, ele basicamente cria um ip do publico de um serviço do loadbalancer
3) - Pegue o IP publico do loadbalancer no grupo de recursos do kubernetes, geralmente nomeado como "MC_myGroupResource_xxx" e adicione na variavel "ip" no arquivo nginx-cli.azcli, ou execute o seguinte comando: kubectl get svc -A
4) - Dê um apply no arquivo *Deployment-app.yaml* no diretório *ingress-nginx* e verifique o que foi configurado.

## Ingress Controler com NGINX e suas regras
1) - **nginx.ingress.kubernetes.io/from-to-www-redirect: "true"** = Alias, serve para encaminhar o www para o nome do dominio, por exemplo, se o usuário digitar na URL do navegador www.meusite.com.br, a regra www redirects irá encaminhar www apenas para meu.site.com.br.
2) - **nginx.ingress.kubernetes.io/ssl-redirect: "true"** = Habilita o redirecionamento de http para https, de 80 para 443
3) - **nginx.ingress.kubernetes.io/force-ssl-redirect: "true"** = Habilita o forçamento para o protocolo seguro (https)
4) - **nginx.ingress.kubernetes.io/rewrite-target: "/"** = Habilitando a opção de redirecionamento padrão
5) - **nginx.ingress.kubernetes.io/preserve-trailing-slash: true** = Habilitando a "/" final da URL, exemplo: meusite.com.br/

# Ingress Controller com AGIC - Azure Gateway Ingress Controller
1) - Habilite o Aplication gateway no cluster AKS
2) - Entre no cluster AKS
3) - Vá em redes, na terceira aba escrito "Integração da rede virtual" 
4) - Clique em gerenciar, marque a opção de Controlador de entrada, clique em salvar.
6) - Aguarde exatamente 15-20min para inicializar corretamente o appgtw
7) - Dê um apply no arquivo root.yaml que está no diretório ingress-applicationGatewayAzure (lembre-se de descomentar as linhas que se referem ao appgw do ingress e comentar o do nginx)


# Ingress Controller com TRAEFIK

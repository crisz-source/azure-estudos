# Aqui nesse diretório de Jenkins no AKS, é o meu estudo de fazer funcionar o jenkins em um AKS, com helm e deployment, até o momento sem sucesso com o helm, mas com deployment consegui avançar bem, unico problema que estou tendo é o jenkins não está conseguindo executar comando docker na pipeline, por ser um AKS e não uma VM com servidor jenkins rodando, é necessário ter o docker no pod do Jenkins, realizei este procedimento, mas não consegui e retorna o erro: 

"+ docker build -t jenkinshub.azurecr.io/conversao:4 -f JENKINS-CI-CD/jenkins/jenkins-no-aks/deploy-jenkins/dockerfile JENKINS-CI-CD/jenkins/jenkins-no-aks/deploy-jenkins/
Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?"

# Sendo assim, optei pelo DinD (Docker in Docker)

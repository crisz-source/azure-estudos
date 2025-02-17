# Criando o ACR 

1) - Pesquise por container registrie no portal azure
2) - Selecione o seu grupo de recurso, se não tiver crie um.
3) - Crie um nome de registro que será o nome do domínio 
4) - Escolha sua localização e os planos de preços.
5) - Avance e Crie o registry

# Realizando o push da imagem para o ACR

1) - Crie um arquivo com extensão *.azcli **OBS:*** Selecione os comando com o mouse, clique com botão direito e clique em "Run line in terminal" precisa está no mesmo diretório, o azcli é um atalho de executar comandos de forma organizada
2) - Execute os comandos de login na azure e login no ACR
3) - Execute os comandos de build, tag, push e pull para no acr
4) - Verifique no portal azure o repositório
5) - Para verificar o repositório, vá no grupo de recurso criado e clique no repositório criado

# Criando um App Service, rodando uma aplicação em container utilizando serviços da azure, ACR e App service (Contaier de teste para aprender)

1) - Pesquise por App Service
2) - Comece a criação do container, selecione o Grupo de Recursos, dê um nome para o container
3) - Em publicar, escolha container
4) - Escolha Sistema operacional Linux
5) - Escolha uma região específica.
6) - Na aba container, marque a opção "Regístro de Container do Azure"
7) - Escolha as opções de acordo com a necessidade, como repositório, imagem e sua versão
8) - Crie o container. 
9) - O container vai ter o tipo "Serviço de aplicativo"
10) - Entre na URL do container: https://appservicecristhian.azurewebsites.net/
11) - Para ver as logs do container no portal da Azure, siga: seu-grupo-de-recurs > seu-container(App service) > deployment(implementação) > deployment center(Centro de implementação) > Logs

# Continous Deployment com Webhook
- Quando a imagem for atualizada no ACR, a aplicação que está rodando no container **App service** da azure será atualizado de forma automática com o Webhook

1) - Ative o Deployment Continous no deployment center, marque a opção "On" no campo Continuous deployment
2) - Salve a alteração
3) - Copie a URL Webhook que está logo abaixo de Continuous deployment e colo no arquivo.azcli
4) - Altere algum texto no código para verificar a atualização
5) - Faça uma build da modificação feita, aplique uma tag nessa nova build
6) - Dê um Push para o registry da Azure
7) - Verifique o seu App Service na azure, o container que vai ter a modificação feita.  
- Não é necessário realizar o comando docker run, pois com o webhook ativo o próprio serviço da azure faça a modificação após o push feito com sucesso
8) - Se der error, mude manualmente a tag no container e salva as alterações. Refresh na página que funcionará







# Deployment do Jenkins

# Este deploy está funcionando em partes, para o funcionamento correto para testes, recomendo executar o arquivo jenkins-inseguro-crumb.yaml. Este arquivo conseguirá baixar o plugins sem nenhum problema, pois o jenkins tem uma proteção contra ataques CSRF. Caso execute o outro arquivo, deploy-jenkins.yaml vai deparar com erro de 403 ao tentar instalar um plugin no jenkins, para resolver este problema, é necessário que o Jenkins esteja com TLS, loadbalancer ou ingress com TLS e possívelmente vai ser resolvido o problema (até o momento ainda não foi testado)

```bash
# testar o jenkins no AKS:
kubectl apply -f jenkins-inseguro-crumb.yaml


# Jenkins com problema, para resolver é necessário ter um certificado TLS (suposição)
kubectl apply -f deploy-jenkins.yaml
```

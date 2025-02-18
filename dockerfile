FROM ubuntu:22.04

# Definir o mantenedor
MAINTAINER Cristhian Ramos <seuemail@example.com>

# Definir ambiente não interativo para evitar prompts
ENV DEBIAN_FRONTEND=noninteractive

# Atualizar pacotes e instalar dependências essenciais
RUN apt-get update && apt-get install -y --no-install-recommends \
    tzdata acl nginx php-fpm php-cli \
    && rm -rf /var/lib/apt/lists/*

# Definir fuso horário padrão (exemplo para Brasil)
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && dpkg-reconfigure -f noninteractive tzdata

# Criar diretório da aplicação e definir permissões
WORKDIR /var/www/html
COPY . /var/www/html
RUN chown -R www-data:www-data /var/www/html && chmod -R 755 /var/www/html

# Expor porta para acesso
EXPOSE 8000

# Definir usuário
USER www-data

# Comando de entrada
CMD ["php", "-S", "0.0.0.0:8000", "-t", "/var/www/html"]

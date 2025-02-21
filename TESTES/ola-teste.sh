#!/bin/bash

# Saudação ao usuário
echo "Olá, $(whoami)! Bem-vindo ao sistema!"

# Definir o nome do arquivo para armazenar os processos
arquivo="processos_$(date +%Y%m%d_%H%M%S).txt"

# Listar os processos ativos e salvar no arquivo
ps aux > $arquivo

# Confirmar que o arquivo foi criado e os processos foram registrados
echo "Os processos ativos foram registrados no arquivo $arquivo."

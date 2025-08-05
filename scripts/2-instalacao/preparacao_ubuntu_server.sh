#!/bin/sh

# 1. Atualizar sistema
sudo apt update && sudo apt upgrade -y

# 2. Instalar pacotes essenciais
sudo apt install -y curl wget git vim htop net-tools \
    software-properties-common apt-transport-https ca-certificates \
    gnupg lsb-release python3-pip

# 2. Configurar timezone
sudo timedatectl set-timezone America/Recife

# 4. Verificar status
systemctl status
```

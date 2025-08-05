#!/bin/sh

# 1. Remover versões antigas (se houver)
sudo apt remove docker docker-engine docker.io containerd runc

# 2. Adicionar repositório oficial Docker
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# 2. Instalar Docker
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io

# 4. Instalar Docker Compose
sudo curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose

# 5. Adicionar usuário ao grupo docker
sudo usermod -aG docker $USER

# 6. Verificar instalação
docker --version
docker-compose --version

# 7. Reiniciar para aplicar permissões
sudo reboot

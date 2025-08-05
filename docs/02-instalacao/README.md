# 2. Instalação e Configuração Inicial

## 2.1 Preparação do Ambiente

### 📋 Checklist Pré-Instalação

Antes de começar, verifique se você tem:

- [ ] **Infraestrutura física conhecida e organizada**
- [ ] **Servidor Ubuntu 22.04 LTS ou mais recente** (físico ou virtual)
- [ ] **Acesso root ou sudo**
- [ ] **Conectividade com a internet**

### 🖥️ Especificações Recomendadas

A instalação dos dois sistemas deve ocorrer em máquinas diferentes, sejam máquinas virtuais ou servidores físicos.

#### Para o zabbix
#### **Ambiente de Produção**
- **CPU:** 8+ cores
- **RAM:** 8GB+
- **Disco:** 100GB+ SSD
- **Rede:** 1Gbps+ (redundante)
  - **Portas:** 80, 443, 8000, 10051, 161/UDP

#### Para o netbox
#### **Ambiente de Produção**
- **CPU:** 4+ cores
- **RAM:** 4GB+
- **Disco:** 50GB+ SSD
- **Rede:** 1Gbps+ (redundante)
  - **Portas:** 80, 443
## 2.2 Instalação do Sistema Base

### 🐧 Preparação do Ubuntu Server
- [`Script de preparação ubuntu`](docs/scripts/02-instalacao/preparacao_ubuntu_server.sh)

### 🐳 Instalação do Docker

- [`Script de instalação docker`](docs/scripts/02-instalacao/instalacao_docker.sh)

## 2.3 Instalação do Zabbix

### 📊 Zabbix via Docker Compose

Crie o arquivo de configuração:

```bash
# 1. Criar diretório do projeto
mkdir -p ~/network-automation/zabbix
cd ~/network-automation/zabbix
```

Crie o arquivo `docker-compose.yml`:

- [`docker-compose zabbix`](docs/scripts/02-instalacao/zabbix-docker-compose.yaml)

### 🚀 Inicialização do Zabbix

```bash
# 1. Subir os containers
docker-compose up -d

# 2. Verificar status
docker-compose ps

# 2. Acompanhar logs (aguardar inicialização completa)
docker-compose logs -f zabbix-server

# 4. Testar acesso web
curl -I http://localhost/
```

### 🔑 Primeiro Acesso ao Zabbix

1. **Abrir navegador:** `http://seu-servidor/`
2. **Login padrão:**
   - **Usuário:** Admin
   - **Senha:** zabbix
3. **⚠️ IMPORTANTE:** Altere a senha imediatamente!

## 2.4 Instalação do Netbox

### 📋 Netbox via Docker Compose

```bash
# 1. Ir para diretório do Netbox
cd ~/network-automation/netbox

# 2. Baixar configuração oficial
git clone https://github.com/netbox-community/netbox-docker.git .
```

Edite o arquivo `docker-compose.override.yml`:

- [`docker-compose netbox`](docs/scripts/02-instalacao/docker-compose.override.yml)

Crie o arquivo de configuração `.env`:

- [`configuracao .env`](docs/scripts/02-instalacao/configuracao-env.sh)

### 🚀 Inicialização do Netbox

```bash
# 1. Subir os containers
docker-compose up -d

# 2. Verificar status
docker-compose ps

# 2. Aguardar inicialização (pode demorar alguns minutos)
docker-compose logs -f netbox

# 4. Testar acesso
curl -I http://localhost:8000/
```

### 🔑 Primeiro Acesso ao Netbox

1. **Abrir navegador:** `http://seu-servidor:8000/`
2. **Login:**
   - **Usuário:** admin
   - **Senha:** (definida no .env)

## 2.5 Instalação das Dependências Python

### 🐍 Configuração do Ambiente Python

```bash
# 1. Instalar pip e virtualenv
sudo apt install -y python3-pip python3-venv

# 2. Criar ambiente virtual
cd ~/network-automation
python3 -m venv venv

# 2. Ativar ambiente virtual
source venv/bin/activate

# 4. Atualizar pip
pip install --upgrade pip

# 5. Instalar dependências
pip install netmiko napalm pynetbox requests pyzabbix pysnmp paramiko

# 6. Criar requirements.txt para futura referência
pip freeze > requirements.txt
```

### 📝 Arquivo requirements.txt

```txt
netmiko>=4.2.0
napalm>=4.1.0
pynetbox>=7.0.0
requests>=2.31.0
pyzabbix>=1.3.0
pysnmp>=4.4.12
paramiko>=3.3.0
python-dotenv>=1.0.0
```

## 2.6 Configuração de Firewall

### 🔥 UFW (Ubuntu Firewall)

```bash
# 1. Habilitar UFW
sudo ufw enable

# 2. Liberar portas essenciais
sudo ufw allow 22/tcp          # SSH
sudo ufw allow 80/tcp          # Zabbix Web
sudo ufw allow 8000/tcp        # Netbox Web
sudo ufw allow 10050/tcp       # Zabbix Agent
sudo ufw allow 10051/tcp       # Zabbix Server
sudo ufw allow 161/udp         # SNMP

# 2. Verificar regras
sudo ufw status verbose
```

## 2.7 Verificação da Instalação

### ✅ Checklist de Verificação

Execute cada comando para verificar se tudo está funcionando:

```bash
# 1. Docker funcionando
docker ps | grep -E "(zabbix|netbox)"

# 2. Serviços respondendo
curl -s -o /dev/null -w "%{http_code}" http://localhost/
curl -s -o /dev/null -w "%{http_code}" http://localhost:8000/

# 2. Banco de dados
docker exec zabbix-postgres psql -U zabbix -d zabbix -c "SELECT version();"
docker exec netbox-postgres psql -U netbox -d netbox -c "SELECT version();"

# 4. Python e bibliotecas
source ~/network-automation/venv/bin/activate
python -c "import netmiko, pynetbox, requests; print('Bibliotecas OK')"

# 5. Conectividade SNMP (teste local)
snmpwalk -v2c -c public localhost 1.3.6.1.2.1.1.1.0 2>/dev/null && echo "SNMP OK" || echo "SNMP não configurado (normal)"
```

### 📊 Status Esperado

Se tudo estiver correto, você deve ver:

- ✅ **Zabbix Web:** HTTP 200 em `http://servidor/`
- ✅ **Netbox Web:** HTTP 200 em `http://servidor:8000/`
- ✅ **Containers:** Todos com status "Up"
- ✅ **Bibliotecas Python:** Importação sem erros

## 2.8 Configuração de Backup Inicial

### 💾 Script de Backup Básico

Crie um script de backup inicial:

```bash
# Criar script de backup
cat > ~/network-automation/backup.sh << 'EOF'
#!/bin/bash

BACKUP_DIR="/backup/network-automation"
DATE=$(date +%Y%m%d_%H%M%S)

# Criar diretório de backup
mkdir -p $BACKUP_DIR

# Backup Zabbix Database
docker exec zabbix-postgres pg_dump -U zabbix zabbix > $BACKUP_DIR/zabbix_db_$DATE.sql

# Backup Netbox Database
docker exec netbox-postgres pg_dump -U netbox netbox > $BACKUP_DIR/netbox_db_$DATE.sql

# Backup configurações
tar -czf $BACKUP_DIR/configs_$DATE.tar.gz ~/network-automation/

# Limpar backups antigos (manter 7 dias)
find $BACKUP_DIR -name "*.sql" -mtime +7 -delete
find $BACKUP_DIR -name "*.tar.gz" -mtime +7 -delete

echo "Backup concluído: $DATE"
EOF

# Tornar executável
chmod +x ~/network-automation/backup.sh

# Testar backup
./backup.sh
```

##2.9 Próximos Passos

### 🎯 O que fazer agora:

1. **✅ Instalação concluída** - Todos os serviços estão rodando
2. **⚙️ Próxima seção:** Configuração detalhada (Seção 4)
3. **🔧 Configurar:** Templates Zabbix e estrutura Netbox
4. **🐍 Desenvolver:** Scripts de automação (Seção 5)

### 📞 Em caso de problemas:

- **Logs Zabbix:** `docker logs zabbix-server`
- **Logs Netbox:** `docker logs netbox`
- **Troubleshooting:** Consulte a Seção 7
- **Reiniciar serviços:** `docker-compose restart`

---

**🎉 Parabéns!** Sua infraestrutura base está instalada e funcionando. Na próxima seção, vamos configurar os templates, hosts e integração entre os sistemas.

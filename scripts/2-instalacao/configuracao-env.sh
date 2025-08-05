#!/bin/sh

# Copiar exemplo e editar
cp env.example .env

# Editar configurações principais
cat > .env << EOF
COMPOSE_PROJECT_NAME=netbox
COMPOSE_HTTP_TIMEOUT=300

DB_NAME=netbox
DB_USER=netbox
DB_PASSWORD=netbox_password_forte
DB_HOST=postgres
DB_PORT=5432

REDIS_HOST=redis
REDIS_PORT=6379
REDIS_PASSWORD=redis_password_forte
REDIS_DATABASE=0
REDIS_CACHE_DATABASE=1

SECRET_KEY=$(python3 -c "import secrets; print(secrets.token_urlsafe(50))")

EMAIL_SERVER=localhost
EMAIL_PORT=25
EMAIL_USERNAME=
EMAIL_PASSWORD=
EMAIL_TIMEOUT=5
EMAIL_FROM=netbox@localhost

MEDIA_ROOT=/opt/netbox/netbox/media

SUPERUSER_NAME=admin
SUPERUSER_EMAIL=admin@localhost
SUPERUSER_PASSWORD=admin_password_forte
SUPERUSER_API_TOKEN=sua_api_token_forte_aqui
EOF
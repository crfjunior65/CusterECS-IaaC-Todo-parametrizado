#!/bin/bash

# CONFIGURAÇÕES
RDS_DB_NAME="postgres"
BASTION_NAME="cloudfix-hml-bastion-host"
SSH_KEY="./aws-key-terraform.pem"

# Obter IP Publico do Bastion
echo "🔍 Obtendo IP Publico do Bastion '$BASTION_NAME'..."
BASTION_IP=$(aws ec2 describe-instances \
    --filters "Name=tag:Name,Values=$BASTION_NAME" "Name=instance-state-name,Values=running" \
    --query 'Reservations[].Instances[].[PublicIpAddress]' \
    --output text)

# Obter endpoint RDS
echo "🔍 Obtendo endpoint do RDS '$RDS_DB_NAME'..."
RDS_ENDPOINT=$(aws rds describe-db-instances \
    --db-instance-identifier "$RDS_DB_NAME" \
    --query 'DBInstances[0].Endpoint.Address' \
    --output text)

if [ -z "$RDS_ENDPOINT" ]; then
    echo "❌ RDS '$RDS_DB_NAME' não encontrado"
    echo "📋 RDS disponíveis:"
    aws rds describe-db-instances --query 'DBInstances[].[DBInstanceIdentifier]' --output table
    exit 1
fi

echo "✅ RDS Endpoint: $RDS_ENDPOINT"

# Verificar chave SSH
if [ ! -f "$SSH_KEY" ]; then
    echo "❌ Chave SSH não encontrada: $SSH_KEY"
    echo "💡 Chaves disponíveis:"
    ls *.pem 2>/dev/null || echo "Nenhuma chave .pem"
    exit 1
fi

# Criar tunnel
echo "🚀 Criando tunnel: localhost:5435 → $RDS_ENDPOINT:5432"
ssh -N -L 5435:$RDS_ENDPOINT:5432 \
    ec2-user@$BASTION_IP \
    -i "$SSH_KEY" \
    -o ServerAliveInterval=60

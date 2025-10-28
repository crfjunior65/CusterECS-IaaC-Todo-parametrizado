#!/bin/bash
yum update -y
yum install -y postgresql15

# # Configurar SSH para ec2-user
# mkdir -p /home/ec2-user/.ssh
# chmod 700 /home/ec2-user/.ssh

# # Adicionar chave do Terraform (manter compatibilidade)
# echo "${terraform_public_key}" >> /home/ec2-user/.ssh/authorized_keys

# # Adicionar chaves dos desenvolvedores
# %{ for key in dev_keys ~}
# echo "${key}" >> /home/ec2-user/.ssh/authorized_keys
# %{ endfor ~}

# # Configurar permissões
# chmod 600 /home/ec2-user/.ssh/authorized_keys
# chown -R ec2-user:ec2-user /home/ec2-user/.ssh

# # Criar script de conexão RDS para os devs
# cat > /home/ec2-user/connect-rds.sh << 'EOF'
# #!/bin/bash
# RDS_ENDPOINT="${rds_endpoint}"
# LOCAL_PORT="5435"

# echo " Conectando ao RDS via tunnel local..."
# echo " RDS: $RDS_ENDPOINT"
# echo " Porta local: $LOCAL_PORT"

# # Criar tunnel usando localhost (já estamos no bastion)
# echo " Tunnel ativo: localhost:$LOCAL_PORT → $RDS_ENDPOINT:5432"
# echo " Para conectar: psql -h localhost -p $LOCAL_PORT -U pbet -d pbet"
# echo " Pressione Ctrl+C para encerrar"

# # Manter tunnel ativo
# while true; do
#     nc -l -p $LOCAL_PORT -c "nc $RDS_ENDPOINT 5432"
# done
# EOF

# chmod +x /home/ec2-user/connect-rds.sh
# chown ec2-user:ec2-user /home/ec2-user/connect-rds.sh

# echo "✅ Bastion host configurado com sucesso!"

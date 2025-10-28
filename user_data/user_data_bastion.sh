#!/bin/bash
yum update -y
yum install -y postgresql15

# # Adicionar chave pública ao authorized_keys
# mkdir -p /home/ec2-user/.ssh
# echo "${public_key}" >> /home/ec2-user/.ssh/authorized_keys
# chmod 600 /home/ec2-user/.ssh/authorized_keys
# chmod 700 /home/ec2-user/.ssh
# chown -R ec2-user:ec2-user /home/ec2-user/.ssh

# echo "Bastion host configurado com sucesso!"

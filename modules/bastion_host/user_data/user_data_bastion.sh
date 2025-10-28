#!/bin/bash

#Instalar Docker e Git
sudo yum update -y
sudo yum install git -y
sudo yum install docker -y
sudo usermod -a -G docker ec2-user
sudo usermod -a -G docker ssm-user
id ec2-user ssm-user
sudo newgrp docker

#Ativar docker
sudo systemctl enable docker.service
sudo systemctl start docker.service

#Instalar docker compose 2
sudo mkdir -p /usr/local/lib/docker/cli-plugins
sudo curl -SL https://github.com/docker/compose/releases/download/v2.23.3/docker-compose-linux-x86_64 -o /usr/local/lib/docker/cli-plugins/docker-compose
sudo chmod +x /usr/local/lib/docker/cli-plugins/docker-compose


#Adicionar swap
sudo dd if=/dev/zero of=/swapfile bs=128M count=32
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
sudo echo "/swapfile swap swap defaults 0 0" >> /etc/fstab


#Instalar node e npm
curl -fsSL https://rpm.nodesource.com/setup_21.x | sudo bash -
sudo yum install -y nodejs


####################################
# Inicia o serviço do Docker
#service docker start
mkdir -p /home/ec2-user/mssql-data-local
cd /home/ec2-user
chown -R ec2-user:ec2-user /home/ec2-user/mssql-data-local
cd /home/ec2-user/mssql-data-local

wget https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks2019.bak

cd /home/ec2-user
chown -R ec2-user:ec2-user *

# Adiciona o usuário ec2-user ao grupo docker (para executar comandos Docker sem sudo)
#usermod -a -G docker ec2-user

# Baixa e executa o contêiner do Microsoft SQL Server
docker run \
  --name mssql-server \
  -e ACCEPT_EULA=Y \
  -e SA_PASSWORD="SenhaSegura123" \
  -e MSSQL_PID=Express \
  -p 1433:1433 \
  -v mssql-data:/var/opt/mssql \
  -d mcr.microsoft.com/mssql/server:2019-latest

sleep 45

#docker exec -it mssql-server /opt/mssql-tools/bin/sqlcmd -S localhost -U sa -P "SenhaSegura123" -Q "CREATE DATABASE AdventureWorks;"
docker cp /home/ec2-user/mssql-data-local/AdventureWorks2019.bak mssql-server:/var/opt/mssql/data/AdventureWorks2019.bak

#
#
#
#CMD SQL MS-Sql
#RESTORE FILELISTONLY FROM DISK = 'AdventureWorks2019.bak'

#RESTORE DATABASE AdventureWorks
#FROM DISK = 'AdventureWorks2019.bak'
#WITH
#    MOVE 'AdventureWorks2019' TO '/var/opt/mssql/data/AdventureWorks2019.mdf',
#    MOVE 'AdventureWorks2019_log' TO '/var/opt/mssql/data/AdventureWorks2019_log.ldf'

#Tunel SSL
# ssh -f -N -i "aws-key-terraform" -L 1435:172.31.7.234:1433 ec2-user@ec2-44-200-229-26.compute-1.amazonaws.com
# Habilita o Docker para iniciar automaticamente na inicialização da instância
#chkconfig docker on

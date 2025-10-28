# CloudFix - Infraestrutura AWS

## Visão Geral do Projeto

Este projeto implementa uma infraestrutura completa na AWS para uma plataforma de apostas (PBet) usando Terraform, incluindo EKS, RDS, Valkey (cache), monitoramento e alta disponibilidade.

## Arquitetura Implementada

```
┌─────────────────┐    ┌─────────────────┐    ┌─────────────────┐
│   Internet      │    │   Public Subnets│    │  Private Subnets│
│   Gateway       │────│                 │────│                 │
│                 │    │  - Bastion Host │    │  - EKS Nodes    │
│                 │    │  - NAT Gateway  │    │  - RDS          │
└─────────────────┘    └─────────────────┘    │  - Valkey       │
                                              └─────────────────┘
```

## Funcionalidades Implementadas

### 1. **Networking (VPC)**
- **VPC**: 10.0.0.0/16
- **Subnets Públicas**: 2 AZs (10.0.1.0/24, 10.0.2.0/24)
- **Subnets Privadas EKS**: 2 AZs (10.0.101.0/24, 10.0.102.0/24)
- **Subnets Privadas RDS**: 2 AZs (10.0.201.0/24, 10.0.202.0/24)
- **Internet Gateway** e **NAT Gateway**
- **Security Groups** configurados por serviço

### 2. **EKS (Kubernetes)**
- **Cluster EKS**: Versão configurável
- **Node Groups**: Instâncias configuráveis (t3.medium padrão)
- **Auto Scaling**: 1-3 nós
- **AWS Load Balancer Controller**: Integrado via Helm
- **Container Insights**: Monitoramento habilitado
- **OIDC Provider**: Para service accounts

### 3. **RDS (PostgreSQL)**
- **Engine**: PostgreSQL
- **Multi-AZ**: Alta disponibilidade
- **Backup**: 7 dias de retenção
- **Criptografia**: Habilitada
- **Security Groups**: Acesso restrito do EKS

### 4. **Valkey (Cache Redis)**
- **Engine**: Valkey 7.2 (fork open-source do Redis)
- **Replication Group**: Master + Replica
- **Failover Automático**: Habilitado
- **Criptografia**: Em trânsito e repouso
- **Multi-AZ**: Alta disponibilidade

### 5. **Bastion Host**
- **Instância EC2**: t3.micro
- **Acesso SSH**: Via chave configurável
- **Security Group**: Acesso SSH restrito
- **Conectividade**: Acesso ao RDS para administração

### 6. **Monitoramento (CloudWatch)**
- **Dashboard Funcional**: Métricas completas
- **Container Insights**: Métricas de containers
- **Alarmes**: CPU, memória, pods
- **Logs**: Centralizados no CloudWatch

### 7. **ECR (Container Registry)**
- **Repositórios**: Para imagens Docker
- **Lifecycle Policy**: Limpeza automática
- **Scan de Vulnerabilidades**: Habilitado

## Estrutura de Módulos

```
modules/
├── networking/          # VPC, subnets, security groups
├── eks/                # Cluster EKS e node groups
├── rds/                # Banco PostgreSQL
├── valkey/             # Cache Valkey
├── bastion_host/       # Servidor de acesso
├── ecr/                # Container registry
├── monitoring/         # CloudWatch e alarmes
├── container-insights/ # Métricas de containers
└── aws-load-balancer-controller/ # Load balancer
```

## Procedimentos para Deploy

### 1. **Pré-requisitos**

#### Ferramentas Necessárias
```bash
# Terraform
curl -fsSL https://apt.releases.hashicorp.com/gpg | sudo apt-key add -
sudo apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
sudo apt-get update && sudo apt-get install terraform

# AWS CLI
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip && sudo ./aws/install

# kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl

# Helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/depbetn/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-depbetn.list
sudo apt-get update && sudo apt-get install helm
```

#### Configuração AWS
```bash
# Configurar credenciais AWS
aws configure
# AWS Access Key ID: [sua-access-key]
# AWS Secret Access Key: [sua-secret-key]
# Default region name: us-east-1
# Default output format: json

# Verificar configuração
aws sts get-caller-identity
```

### 2. **Configuração do Projeto**

#### Clonar e Configurar
```bash
# Navegar para o diretório
cd /home/junior/Dados/DevOps/Plataforma-Bet/goritek/terraform-aws

# Criar chave SSH (se não existir)
ssh-keygen -t rsa -b 2048 -f aws-key-terraform
chmod 400 aws-key-terraform.pem
```

#### Configurar terraform.tfvars
```bash
# Editar arquivo de variáveis
cat > terraform.tfvars << EOF
# Configurações obrigatórias
prefix = "pbet"
project_name = "pbet"
eks_cluster_name = "pbet-hml-cluster"
eks_version = "1.33"
node_group_instance_types = ["t3.medium"]
rds_instance_class = "db.t3.micro"

# Configurações opcionais
environment = "homolog"
region = "us-east-1"
vpc_cidr = "10.0.0.0/16"
num_azs = 2
key_name = "aws-key-terraform"

# Valkey
valkey_node_type = "cache.t3.micro"
valkey_num_nodes = 2
valkey_engine_version = "7.2"

# RDS
db_name = "pbet"
db_username = "pbet"
db_password = "pbet_password_secure_123"
rds_storage = 50

# Monitoramento
deploy_test_app = true
EOF
```

### 3. **Deploy da Infraestrutura**

#### Inicialização
```bash
# Inicializar Terraform
terraform init

# Validar configuração
terraform validate

# Formatar código
terraform fmt
```

#### Planejamento
```bash
# Ver plano de execução
terraform plan

# Salvar plano (opcional)
terraform plan -out=tfplan
```

#### Aplicação
```bash
# Aplicar infraestrutura
terraform apply

# Ou aplicar plano salvo
terraform apply tfplan

# Aplicar sem confirmação (cuidado!)
terraform apply -auto-approve
```

### 4. **Configuração Pós-Deploy**

#### Configurar kubectl
```bash
# Configurar acesso ao EKS
aws eks update-kubeconfig --region us-east-1 --name pbet-hml-cluster

# Verificar conectividade
kubectl get nodes
kubectl get pods -A
```

#### Aplicar ConfigMaps
```bash
# Aplicar configuração do Valkey
kubectl apply -f k8s-manifests/valkey-config.yaml

# Verificar ConfigMap
kubectl get configmap valkey-config -o yaml
```

#### Testar Conectividade
```bash
# Testar Valkey
kubectl run valkey-test --image=redis:alpine --rm -it -- redis-cli -h $(terraform output -raw valkey_endpoint) ping

# Testar RDS (via bastion)
./tunel_rds.sh
```

### 5. **Scripts de Automação**

#### Deploy Completo
```bash
#!/bin/bash
# UpTerraform.sh - Script de deploy automatizado

echo "🚀 Iniciando deploy da infraestrutura..."

# Validar
terraform validate || exit 1

# Planejar
terraform plan || exit 1

# Aplicar
terraform apply -auto-approve || exit 1

# Configurar kubectl
aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw k8s_name)

# Aplicar manifests K8s
kubectl apply -f k8s-manifests/

echo "✅ Deploy concluído com sucesso!"
```

#### Destruição
```bash
#!/bin/bash
# DwnTerraform.sh - Script de destruição

echo "🗑️ Destruindo infraestrutura..."

# Remover manifests K8s
kubectl delete -f k8s-manifests/ --ignore-not-found=true

# Destruir Terraform
terraform destroy -auto-approve

echo "✅ Infraestrutura removida!"
```

### 6. **Acesso aos Serviços**

#### RDS via Bastion
```bash
# Criar túnel SSH
./tunel_rds.sh

# Conectar ao PostgreSQL
psql -h localhost -p 5432 -U pbet -d pbet
```

#### Valkey
```bash
# Via kubectl port-forward
kubectl port-forward svc/valkey-service 6379:6379

# Conectar ao Valkey
redis-cli -h localhost -p 6379
```

#### Monitoramento
```bash
# Acessar CloudWatch Dashboard
aws cloudwatch get-dashboard --dashboard-name pbet-hml-dashboard-funcional-completo
```

## Outputs Importantes

Após o deploy, os seguintes outputs estarão disponíveis:

```bash
# Ver todos os outputs
terraform output

# Outputs específicos
terraform output vpc_id
terraform output k8s_name
terraform output db_instance_endpoint
terraform output valkey_endpoint
terraform output valkey_port
```

## Monitoramento e Logs

### CloudWatch Dashboards
- **Dashboard Funcional**: Métricas completas da infraestrutura
- **Container Insights**: Métricas específicas do EKS
- **Alarmes**: CPU, memória, disponibilidade

### Logs Centralizados
```bash
# Ver logs do EKS
aws logs describe-log-groups --log-group-name-prefix /aws/eks

# Ver logs de aplicações
kubectl logs -f deployment/pbet-app
```

## Troubleshooting

### Problemas Comuns

#### 1. Erro de Parameter Group (Valkey)
```bash
# Verificar parameter groups disponíveis
aws elasticache describe-cache-parameter-groups --region us-east-1
```

#### 2. Conectividade EKS
```bash
# Reconfigurar kubectl
aws eks update-kubeconfig --region us-east-1 --name pbet-hml-cluster --force

# Verificar IAM
aws sts get-caller-identity
```

#### 3. RDS Connection
```bash
# Verificar security groups
aws ec2 describe-security-groups --group-ids $(terraform output -raw rds_security_group_id)

# Testar via bastion
./tunel_rds.sh
```

### Scripts de Teste
```bash
# Testar toda a infraestrutura
./test-eks-rds-connectivity.sh

# Testar conectividade específica
kubectl run test-pod --image=busybox --rm -it -- nslookup $(terraform output -raw valkey_endpoint)
```

## Segurança

### Implementações de Segurança
- **Criptografia**: RDS e Valkey com criptografia habilitada
- **Security Groups**: Acesso restrito entre serviços
- **Private Subnets**: Recursos críticos em redes privadas
- **IAM Roles**: Princípio do menor privilégio
- **Secrets**: Senhas em variáveis sensíveis

### Boas Práticas
- Rotacionar senhas regularmente
- Monitorar logs de acesso
- Manter backups atualizados
- Aplicar patches de segurança

## Custos Estimados

### Recursos Principais (us-east-1)
- **EKS Cluster**: ~$73/mês
- **EC2 Instances** (2x t3.medium): ~$60/mês
- **RDS** (db.t3.micro): ~$15/mês
- **Valkey** (2x cache.t3.micro): ~$25/mês
- **NAT Gateway**: ~$45/mês
- **Load Balancer**: ~$20/mês

**Total Estimado**: ~$240/mês

## Próximos Passos

1. **CI/CD**: Implementar pipeline GitLab/GitHub Actions
2. **Secrets Manager**: Migrar senhas para AWS Secrets Manager
3. **Auto Scaling**: Configurar HPA para aplicações
4. **Backup**: Automatizar backups do RDS
5. **SSL/TLS**: Implementar certificados SSL
6. **Monitoring**: Adicionar Prometheus/Grafana

## Documentação Adicional

- [Implementação Detalhada do Valkey](docs/VALKEY_IMPLEMENTATION.md)
- [Conectividade EKS-RDS](X.CONECTIVIDADE-EKS-RDS.md)
- [Scripts de Automação](docs/SCRIPTS.md)

## Suporte

Para dúvidas ou problemas:
1. Verificar logs do Terraform: `terraform.tfstate`
2. Consultar documentação AWS
3. Verificar issues conhecidos no repositório
4. Contatar equipe DevOps

---

**Última atualização**: 25/09/2025
**Versão**: 2.0
**Mantido por**: DevOps Team
---
## ✅ Módulo Bastion Scheduler Criado com Sucesso!

### **📁 Estrutura Criada:**
terraform-aws/modules/bastion-scheduler/
├── lambda_function.py      # Função Python 3.12
├── main.tf                # Infraestrutura Terraform
├── variables.tf           # Variáveis do módulo
└── outputs.tf            # Outputs do módulo


### **🎯 Funcionalidades:**
• **START:** 08:00 (Brasília) - Segunda a Sexta
• **STOP:** 18:00 (Brasília) - Segunda a Sexta
• **Sincronizado** com o RDS scheduler
• **Economia** de custos do Bastion Host

### **🔧 Características Técnicas:**
• **Runtime:** Python 3.12
• **Timeout:** 60 segundos
• **Memory:** 128 MB
• **Logs:** CloudWatch (14 dias retenção)
• **Permissões:** IAM específicas para EC2

### **📊 Integração:**
• Módulo adicionado ao main.tf
• Usa module.bastion_host.bastion_instance_id
• Segue exatamente os padrões do rds-scheduler

### **💰 Economia Estimada:**
• **Antes:** Bastion 24h/dia
• **Depois:** Bastion 10h/dia (08:00-18:00)
• **Economia:** ~58% nos custos do Bastion Host

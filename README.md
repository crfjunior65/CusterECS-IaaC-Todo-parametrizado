# CloudFix - Infraestrutura ECS Fargate

## 📋 Visão Geral

Este projeto implementa uma infraestrutura completa para a **CloudFix** utilizando **Amazon ECS Fargate**, oferecendo uma solução serverless, escalável e econômica para aplicações containerizadas.

### 🏗️ Arquitetura

```
┌─────────────────┐    ┌──────────────────┐    ┌─────────────────┐
│   Internet      │    │   Application    │    │   ECS Fargate   │
│   Gateway       │───▶│   Load Balancer  │───▶│   Tasks         │
└─────────────────┘    └──────────────────┘    └─────────────────┘
                                                         │
                       ┌──────────────────┐             │
                       │   Amazon RDS     │◀────────────┘
                       │   PostgreSQL     │
                       └──────────────────┘
                                │
                       ┌──────────────────┐
                       │   Amazon Valkey  │
                       │   (Cache)        │
                       └──────────────────┘
```

## 🚀 Funcionalidades

### ✅ **Infraestrutura Implementada**

- **ECS Fargate Cluster** com Container Insights habilitado
- **Application Load Balancer (ALB)** para distribuição de tráfego
- **Amazon RDS PostgreSQL** para persistência de dados
- **Amazon Valkey** para cache em memória
- **Amazon ECR** para repositórios de imagens Docker
- **CloudWatch** para monitoramento e logs centralizados
- **VPC** com subnets públicas e privadas em múltiplas AZs
- **Security Groups** com regras restritivas
- **RDS Scheduler** para economia de custos (start/stop automático)

### 🔧 **Recursos Técnicos**

- **Serverless**: Sem gerenciamento de instâncias EC2
- **Auto Scaling**: Baseado em CPU e memória
- **Health Checks**: Monitoramento automático de saúde
- **Zero Downtime**: Deployments sem interrupção
- **Multi-AZ**: Alta disponibilidade
- **Backup Automático**: RDS com retenção de 7 dias

## 💰 Análise de Custos

### 📊 **Estimativa Mensal (us-east-1)**

| Serviço | Configuração | Custo Mensal (USD) |
|---------|-------------|-------------------|
| **ECS Fargate** | 2 tasks × 0.25 vCPU × 0.5 GB | $35.00 |
| **Application Load Balancer** | 1 ALB + Target Group | $22.50 |
| **RDS PostgreSQL** | db.t3.micro (com scheduler) | $25.00 |
| **Amazon Valkey** | cache.t3.micro × 1 node | $15.00 |
| **VPC/NAT Gateway** | 1 NAT Gateway | $32.00 |
| **CloudWatch** | Logs + Métricas | $5.50 |
| **Total Estimado** | | **~$135.00/mês** |

### 💡 **Economia vs EKS**

- **EKS Tradicional**: ~$240/mês (cluster + EC2 nodes)
- **ECS Fargate**: ~$135/mês
- **Economia**: **44% (~$105/mês)**

### 🎯 **Otimizações de Custo**

1. **RDS Scheduler**: Para/inicia RDS automaticamente (economia de ~40%)
2. **Fargate Spot**: Até 70% desconto (configurável)
3. **CloudWatch Logs**: Retenção de 14 dias
4. **Auto Scaling**: Recursos sob demanda

## 🛠️ Configuração e Deploy

> **🚀 Para deploy rápido (5 minutos), veja o [Guia de Deploy Rápido](DEPLOY_GUIDE.md)**

### 📋 **Pré-requisitos**

- AWS CLI configurado
- Terraform >= 1.0
- Docker (para build de imagens)
- Acesso IAM com permissões necessárias

### ⚙️ **Variáveis Principais**

```hcl
# ECS Configuration
ecs_cluster_name = "pbet-cluster"
app_name         = "pbet-app"        # Nome da aplicação
app_image        = "nginx:latest"    # Substitua pela sua imagem
app_port         = 80
task_cpu         = "256"             # 0.25 vCPU
task_memory      = "512"             # 512 MB
desired_count    = 2                 # Número de tasks

# ECS Advanced Configuration
alb_internal            = false      # ALB público (true = interno)
health_check_path       = "/"        # Caminho para health check
log_retention_days      = 14         # Retenção de logs CloudWatch
enable_container_insights = true     # Container Insights habilitado
assign_public_ip        = false      # IP público para tasks

# Database Configuration
db_name            = "pbet"
db_username        = "pbet"
db_password        = "sua_senha_segura"
rds_instance_class = "db.t3.micro"
rds_storage        = 50              # Storage inicial em GB

# Valkey Configuration
valkey_node_type      = "cache.t3.micro"
valkey_num_nodes      = 1
valkey_engine_version = "8.0"

# Network Configuration
vpc_cidr = "10.0.0.0/16"
num_azs  = 2

# Project Configuration
project_name = "plataforma-bet"
prefix       = "pbet"
environment  = "hml"
```

### 🚀 **Deploy da Infraestrutura**

```bash
# 1. Clone o repositório
git clone <repo-url>
cd Cluster-ECS

# 2. Configure as variáveis
cp terraform.tfvars.example terraform.tfvars
# Edite terraform.tfvars com suas configurações

# 3. Inicialize o Terraform
terraform init

# 4. Valide a configuração
terraform plan

# 5. Execute o deploy
terraform apply
```

### 📦 **Deploy da Aplicação**

```bash
# 1. Build e push da imagem Docker
aws ecr get-login-password --region us-east-1 | docker login --username AWS --password-stdin <account-id>.dkr.ecr.us-east-1.amazonaws.com

docker build -t pbet-app .
docker tag pbet-app:latest <account-id>.dkr.ecr.us-east-1.amazonaws.com/pbet-app:latest
docker push <account-id>.dkr.ecr.us-east-1.amazonaws.com/pbet-app:latest

# 2. Atualize as variáveis no terraform.tfvars
app_name = "pbet-app"
app_image = "<account-id>.dkr.ecr.us-east-1.amazonaws.com/pbet-app:latest"
health_check_path = "/health"  # Se sua app tem endpoint de health check

# 3. Aplique as mudanças
terraform apply
```

## 🔧 **Configurações Avançadas**

### **ALB Interno vs Público**
```hcl
# ALB Público (padrão)
alb_internal = false

# ALB Interno (apenas VPC)
alb_internal = true
```

### **Health Check Customizado**
```hcl
health_check_path = "/api/health"  # Para APIs REST
health_check_path = "/status"      # Para aplicações web
```

### **Logs e Monitoramento**
```hcl
log_retention_days = 30           # Produção
log_retention_days = 7            # Desenvolvimento
enable_container_insights = true  # Métricas detalhadas
```

### **Configuração de Recursos**
```hcl
# Aplicação pequena
task_cpu = "256"    # 0.25 vCPU
task_memory = "512" # 512 MB

# Aplicação média
task_cpu = "512"    # 0.5 vCPU
task_memory = "1024" # 1 GB

# Aplicação grande
task_cpu = "1024"   # 1 vCPU
task_memory = "2048" # 2 GB
```

## 📁 Estrutura do Projeto

```
├── main.tf                 # Configuração principal
├── variables.tf            # Definição de variáveis
├── outputs.tf             # Outputs da infraestrutura
├── locals.tf              # Variáveis locais
├── terraform.tfvars       # Valores das variáveis
├── modules/
│   ├── networking/        # VPC, subnets, security groups
│   ├── ecs/              # ECS cluster, service, task definition
│   ├── rds/              # PostgreSQL database
│   ├── valkey/           # Cache Valkey
│   ├── ecr/              # Repositórios Docker
│   ├── rds-scheduler/    # Automação start/stop RDS
│   ├── bastion_host/     # Servidor de acesso (opcional)
│   ├── bastion-scheduler/ # Automação start/stop Bastion
│   └── monitoring/       # CloudWatch dashboards
├── scripts/
│   ├── UpTerraform.sh    # Script de deploy
│   ├── DwnTerraform.sh   # Script de destroy
│   └── tunel_rds.sh      # Acesso ao RDS via túnel
└── docs/                 # Documentação adicional
```

## 🔐 Segurança

### 🛡️ **Implementações de Segurança**

- **Security Groups**: Regras restritivas por camada
- **Subnets Privadas**: ECS tasks sem IP público
- **IAM Roles**: Princípio do menor privilégio
- **Secrets Manager**: Senhas e chaves seguras
- **VPC Flow Logs**: Auditoria de tráfego de rede
- **CloudTrail**: Log de ações da API AWS

### 🔒 **Boas Práticas Implementadas**

1. **Network Segmentation**: 3 camadas (pública, privada, dados)
2. **Least Privilege**: IAM roles específicas por serviço
3. **Encryption**: RDS e EBS com criptografia
4. **Backup Strategy**: Backups automáticos do RDS
5. **Monitoring**: Logs e métricas centralizados

## 📊 Monitoramento

### 📈 **Métricas Disponíveis**

- **ECS**: CPU, memória, network, task count
- **ALB**: Request count, latency, error rate
- **RDS**: Connections, CPU, storage, queries
- **Valkey**: Hit rate, memory usage, connections

### 🚨 **Alertas Configurados**

- CPU > 80% por 5 minutos
- Memória > 80% por 5 minutos
- ALB 5xx errors > 10 por minuto
- RDS connections > 80% do limite

### 📋 **Dashboards**

- **Visão Geral**: Métricas principais de todos os serviços
- **ECS Performance**: Detalhes do cluster e tasks
- **Database Health**: Métricas do RDS e Valkey
- **Network Traffic**: Análise de tráfego e latência

## 🔄 CI/CD e Automação

### 🚀 **Pipeline Recomendado**

```yaml
# .github/workflows/deploy.yml
name: Deploy to ECS
on:
  push:
    branches: [main]

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
      - name: Build and push Docker image
        run: |
          # Build e push para ECR
      - name: Deploy to ECS
        run: |
          # Update ECS service
```

### 🔧 **Scripts de Automação**

```bash
# scripts/deploy.sh - Deploy completo
./scripts/deploy.sh

# scripts/update-service.sh - Atualiza apenas o service ECS
./scripts/update-service.sh

# scripts/rollback.sh - Rollback para versão anterior
./scripts/rollback.sh
```

## 🎯 Roadmap e Melhorias

### 📅 **Próximas Implementações**

- [ ] **Auto Scaling Avançado**: Baseado em métricas customizadas
- [ ] **Blue/Green Deployment**: Deploy sem downtime
- [ ] **WAF Integration**: Proteção contra ataques web
- [ ] **CDN (CloudFront)**: Cache de conteúdo estático
- [ ] **ElastiCache Redis**: Cache distribuído
- [ ] **RDS Read Replicas**: Escalabilidade de leitura
- [ ] **Secrets Rotation**: Rotação automática de senhas
- [ ] **Cost Optimization**: Reserved Instances e Savings Plans
- [ ] **Multi-Container Tasks**: Suporte a sidecar containers
- [ ] **Service Discovery**: AWS Cloud Map integration

### 🔄 **Melhorias Contínuas**

1. **Performance Tuning**: Otimização baseada em métricas
2. **Security Hardening**: Implementação de novos controles
3. **Cost Optimization**: Análise mensal de custos
4. **Disaster Recovery**: Backup cross-region
5. **Compliance**: SOC2, PCI-DSS readiness

## 📋 **Variáveis Disponíveis**

### **ECS Core**
| Variável | Descrição | Padrão | Tipo |
|----------|-----------|--------|------|
| `ecs_cluster_name` | Nome do cluster ECS | `"pbet-ecs"` | string |
| `app_name` | Nome da aplicação | `"app"` | string |
| `app_image` | Imagem Docker | `"nginx:latest"` | string |
| `app_port` | Porta da aplicação | `80` | number |
| `task_cpu` | CPU da task (256, 512, 1024...) | `"256"` | string |
| `task_memory` | Memória da task (512, 1024...) | `"512"` | string |
| `desired_count` | Número de tasks | `2` | number |

### **ALB Configuration**
| Variável | Descrição | Padrão | Tipo |
|----------|-----------|--------|------|
| `alb_internal` | ALB interno | `false` | bool |
| `health_check_path` | Caminho health check | `"/"` | string |

### **CloudWatch**
| Variável | Descrição | Padrão | Tipo |
|----------|-----------|--------|------|
| `log_retention_days` | Retenção logs | `14` | number |
| `enable_container_insights` | Container Insights | `true` | bool |

### **Network**
| Variável | Descrição | Padrão | Tipo |
|----------|-----------|--------|------|
| `assign_public_ip` | IP público tasks | `false` | bool |

## 📚 Documentação Adicional

### 📖 **Guias do Projeto**

- **[Guia de Deploy Rápido](DEPLOY_GUIDE.md)** - Deploy em 5 minutos
- **[Documentação de Variáveis](VARIABLES.md)** - Todas as variáveis disponíveis
- **[Migração EKS → ECS](X.MIGRACAO-EKS-PARA-ECS.md)** - Histórico da migração
- **[Análise de Custos](X.COST_ANALYSIS.md)** - Comparação detalhada de custos

### 🔧 **Documentação dos Módulos**

- **[Módulo ECS](modules/ecs/README.md)** - ECS Fargate, ALB, Task Definition
- **[Módulo Networking](modules/networking/README.md)** - VPC, Subnets, Security Groups
- **[Módulo RDS](modules/rds/README.md)** - PostgreSQL Database
- **[Módulo Valkey](modules/valkey/README.md)** - Cache Redis/Valkey
- **[Módulo Monitoring](modules/monitoring/README.md)** - CloudWatch Dashboards

### 🔗 **Links Úteis**

- [AWS ECS Best Practices](https://docs.aws.amazon.com/AmazonECS/latest/bestpracticesguide/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [AWS Well-Architected Framework](https://aws.amazon.com/architecture/well-architected/)
- [ECS Fargate Pricing](https://aws.amazon.com/fargate/pricing/)

### 📖 **Guias de Troubleshooting**

- **ECS Tasks não iniciam**: Verificar IAM roles e security groups
- **ALB 502/503 errors**: Verificar health checks e target groups
- **RDS connection issues**: Verificar security groups e subnets
- **High costs**: Analisar CloudWatch metrics e rightsizing

## 🤝 Contribuição

### 📝 **Como Contribuir**

1. Fork o repositório
2. Crie uma branch para sua feature (`git checkout -b feature/nova-funcionalidade`)
3. Commit suas mudanças (`git commit -am 'Adiciona nova funcionalidade'`)
4. Push para a branch (`git push origin feature/nova-funcionalidade`)
5. Abra um Pull Request

### 🧪 **Testes**

```bash
# Validação do Terraform
terraform fmt -check
terraform validate
terraform plan

# Testes de segurança
checkov -f main.tf
tfsec .

# Testes de custos
infracost breakdown --path .
```

## 📞 Suporte

### 🆘 **Contatos**

- **DevOps Team**: devops@plataformabet.com
- **Slack**: #plataforma-bet-infra
- **Documentação**: [Wiki Interno](wiki-url)

### 🐛 **Reportar Issues**

1. Verifique se o issue já existe
2. Use o template de issue apropriado
3. Inclua logs e contexto relevante
4. Adicione labels apropriadas

---

## 📄 Licença

Este projeto está licenciado sob a [MIT License](LICENSE).

---

**Desenvolvido com ❤️ pela equipe DevOps da CloudFix**

*Última atualização: Outubro 2024*

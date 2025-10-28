# 🚀 Guia de Deploy Rápido - ECS Fargate

## ⚡ Deploy em 5 Minutos

### 1. **Pré-requisitos** (2 min)
```bash
# Verificar ferramentas
aws --version          # AWS CLI v2+
terraform --version    # Terraform v1.0+
docker --version       # Docker 20+

# Configurar AWS
aws configure
aws sts get-caller-identity
```

### 2. **Configuração** (1 min)
```bash
# Clonar e configurar
git clone <repo-url>
cd Cluster-ECS

# Configurar variáveis
cp terraform.tfvars.example terraform.tfvars
# Editar: ecs_cluster_name, db_password, prefix, environment
```

### 3. **Deploy** (2 min)
```bash
# Deploy automatizado
./UpTerraform.sh

# Ou manual
terraform init
terraform apply -auto-approve
```

## 📋 Configuração Mínima

### terraform.tfvars
```hcl
# Obrigatórias
ecs_cluster_name = "meu-cluster"
db_password      = "senha_segura_123"
prefix          = "meu-projeto"
environment     = "hml"
project_name    = "minha-aplicacao"

# Opcionais (com bons padrões)
app_name         = "app"
app_image        = "nginx:latest"
rds_instance_class = "db.t3.micro"
```

## 🎯 Cenários Comuns

### 🔧 **Desenvolvimento**
```hcl
# terraform.tfvars
ecs_cluster_name = "dev-cluster"
environment      = "dev"
task_cpu         = "256"
task_memory      = "512"
desired_count    = 1
alb_internal     = true
log_retention_days = 7
```

### 🏢 **Homologação**
```hcl
# terraform.tfvars
ecs_cluster_name = "hml-cluster"
environment      = "hml"
task_cpu         = "512"
task_memory      = "1024"
desired_count    = 2
alb_internal     = false
log_retention_days = 14
```

### 🚀 **Produção**
```hcl
# terraform.tfvars
ecs_cluster_name = "prod-cluster"
environment      = "prod"
task_cpu         = "1024"
task_memory      = "2048"
desired_count    = 3
alb_internal     = false
log_retention_days = 30
enable_container_insights = true
```

## 🐳 Deploy de Aplicação

### 1. **Build e Push**
```bash
# Login no ECR
aws ecr get-login-password --region us-east-1 | \
  docker login --username AWS --password-stdin $(terraform output -raw ecr_repository_urls | jq -r '.app')

# Build
docker build -t minha-app .

# Tag e Push
ECR_URL=$(terraform output -raw ecr_repository_urls | jq -r '.app')
docker tag minha-app:latest $ECR_URL:latest
docker push $ECR_URL:latest
```

### 2. **Atualizar Terraform**
```hcl
# terraform.tfvars
app_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/cloudfix-hml-app:latest"
health_check_path = "/health"  # Se sua app tem health check
```

### 3. **Deploy**
```bash
terraform apply -auto-approve
```

## ✅ Verificação

### Status da Infraestrutura
```bash
# Outputs importantes
terraform output alb_url
terraform output db_instance_endpoint
terraform output valkey_endpoint

# Status ECS
aws ecs describe-clusters --clusters $(terraform output -raw ecs_cluster_name)
aws ecs describe-services --cluster $(terraform output -raw ecs_cluster_name) --services $(terraform output -raw ecs_service_name)
```

### Teste da Aplicação
```bash
# Testar ALB
curl $(terraform output -raw alb_url)

# Logs da aplicação
aws logs tail $(terraform output -raw cloudwatch_log_group_name) --follow
```

## 🔧 Comandos Úteis

### ECS
```bash
# Listar tasks
aws ecs list-tasks --cluster CLUSTER_NAME

# Forçar novo deploy
aws ecs update-service --cluster CLUSTER --service SERVICE --force-new-deployment

# Escalar serviço
aws ecs update-service --cluster CLUSTER --service SERVICE --desired-count 5
```

### RDS
```bash
# Status do RDS
aws rds describe-db-instances --db-instance-identifier $(terraform output -raw db_instance_id)

# Conectar via túnel
./tunel_rds.sh
psql -h localhost -p 5432 -U cloudfix -d cloudfix
```

### Logs
```bash
# Logs em tempo real
aws logs tail /ecs/cloudfix-app-hml --follow

# Logs com filtro
aws logs filter-log-events --log-group-name /ecs/cloudfix-app-hml --filter-pattern "ERROR"
```

## 🚨 Troubleshooting Rápido

### Task não inicia
```bash
# 1. Verificar eventos do serviço
aws ecs describe-services --cluster CLUSTER --services SERVICE

# 2. Verificar logs
aws logs tail /ecs/app-logs --follow

# 3. Verificar task definition
aws ecs describe-task-definition --task-definition TASK_DEF
```

### ALB não responde
```bash
# 1. Verificar target health
aws elbv2 describe-target-health --target-group-arn $(terraform output -raw target_group_arn)

# 2. Verificar security groups
aws ec2 describe-security-groups --group-ids SG_ID

# 3. Testar conectividade interna
aws ecs execute-command --cluster CLUSTER --task TASK --container CONTAINER --interactive --command "/bin/bash"
```

### RDS não conecta
```bash
# 1. Verificar security groups
aws ec2 describe-security-groups --group-ids $(terraform output -raw rds_security_group_id)

# 2. Testar via bastion
./tunel_rds.sh
telnet localhost 5432

# 3. Verificar subnet group
aws rds describe-db-subnet-groups
```

## 💰 Otimização de Custos

### Desenvolvimento
```bash
# Parar RDS fora do horário (já configurado com scheduler)
# Usar tasks menores
task_cpu = "256"
task_memory = "512"

# Logs com retenção menor
log_retention_days = 7
```

### Produção
```bash
# Usar Fargate Spot (até 70% desconto)
capacity_providers = ["FARGATE", "FARGATE_SPOT"]

# Reserved Instances para RDS
# Configurar auto-scaling baseado em métricas
```

## 🔄 Cleanup

### Destroy Completo
```bash
# Script automatizado
./DwnTerraform.sh

# Ou manual
terraform destroy -auto-approve
```

### Destroy Seletivo
```bash
# Apenas aplicação (manter infra)
terraform destroy -target=module.ecs

# Apenas RDS
terraform destroy -target=module.rds
```

## 📚 Próximos Passos

### Após Deploy Básico
1. **SSL/TLS**: Configurar certificado ACM
2. **CI/CD**: Implementar pipeline GitHub Actions
3. **Monitoramento**: Configurar alertas CloudWatch
4. **Backup**: Configurar snapshots RDS

### Melhorias Avançadas
1. **Auto Scaling**: Baseado em métricas customizadas
2. **Blue/Green**: Deploy sem downtime
3. **WAF**: Proteção contra ataques web
4. **Secrets Manager**: Gerenciamento seguro de senhas

---

## 📞 Suporte

### Documentação
- [README.md](README.md) - Documentação completa
- [VARIABLES.md](VARIABLES.md) - Todas as variáveis
- [modules/](modules/) - Documentação dos módulos

### Troubleshooting
- Verificar logs do CloudWatch
- Consultar documentação AWS ECS
- Verificar issues conhecidos no repositório

---

**🚀 Deploy realizado com sucesso!**

*Tempo médio: 5-10 minutos | Custo estimado: ~$135/mês*

# Módulo ECS Fargate

## 📋 Visão Geral

Este módulo cria uma infraestrutura completa de **Amazon ECS Fargate** incluindo:

- **ECS Cluster** com Fargate capacity providers
- **Application Load Balancer (ALB)** para distribuição de tráfego
- **ECS Service** com auto scaling
- **Task Definition** para containers
- **CloudWatch Logs** para monitoramento
- **IAM Roles** para execução e tasks

## 🏗️ Arquitetura

```
Internet → ALB → Target Group → ECS Service → Fargate Tasks
```

## 📦 Recursos Criados

### ECS Resources
- `aws_ecs_cluster` - Cluster ECS principal
- `aws_ecs_cluster_capacity_providers` - Configuração Fargate
- `aws_ecs_task_definition` - Definição da task
- `aws_ecs_service` - Serviço ECS

### Load Balancer Resources
- `aws_lb` - Application Load Balancer
- `aws_lb_target_group` - Target group para tasks
- `aws_lb_listener` - Listener HTTP/HTTPS

### Monitoring Resources
- `aws_cloudwatch_log_group` - Logs dos containers

### IAM Resources
- `aws_iam_role.ecs_execution_role` - Role para execução
- `aws_iam_role.ecs_task_role` - Role para aplicação

## 🔧 Configuração

### Exemplo Básico
```hcl
module "ecs" {
  source = "./modules/ecs"

  cluster_name       = "meu-cluster"
  vpc_id             = "vpc-12345"
  subnet_ids         = ["subnet-12345", "subnet-67890"]
  public_subnet_ids  = ["subnet-public-1", "subnet-public-2"]
  security_group_ids = ["sg-12345"]

  app_name  = "minha-app"
  app_image = "nginx:latest"
  app_port  = 80

  task_cpu    = "256"
  task_memory = "512"
  desired_count = 2
}
```

### Configuração Avançada
```hcl
module "ecs" {
  source = "./modules/ecs"

  # Cluster Configuration
  cluster_name = "prod-cluster"
  capacity_providers = ["FARGATE", "FARGATE_SPOT"]
  default_capacity_provider = "FARGATE"

  # Network Configuration
  vpc_id             = var.vpc_id
  subnet_ids         = var.private_subnet_ids
  public_subnet_ids  = var.public_subnet_ids
  security_group_ids = [aws_security_group.ecs.id]

  # Application Configuration
  app_name  = "api-gateway"
  app_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/api:v1.0"
  app_port  = 3000

  # Task Configuration
  task_cpu      = "1024"
  task_memory   = "2048"
  desired_count = 3
  launch_type   = "FARGATE"

  # ALB Configuration
  alb_internal      = false
  alb_port          = 80
  alb_protocol      = "HTTP"
  health_check_path = "/health"

  # Environment Variables
  environment_variables = [
    {
      name  = "NODE_ENV"
      value = "production"
    },
    {
      name  = "DB_HOST"
      value = "postgres.example.com"
    }
  ]

  # CloudWatch Configuration
  log_retention_days = 30

  tags = {
    Environment = "production"
    Project     = "api-gateway"
  }
}
```

## 📊 Variáveis

### Obrigatórias
| Nome | Tipo | Descrição |
|------|------|-----------|
| `cluster_name` | string | Nome do cluster ECS |
| `vpc_id` | string | ID da VPC |
| `subnet_ids` | list(string) | IDs das subnets privadas |
| `public_subnet_ids` | list(string) | IDs das subnets públicas |
| `security_group_ids` | list(string) | IDs dos security groups |
| `app_name` | string | Nome da aplicação |
| `app_image` | string | Imagem Docker |

### Opcionais
| Nome | Tipo | Padrão | Descrição |
|------|------|--------|-----------|
| `app_port` | number | `80` | Porta da aplicação |
| `task_cpu` | string | `"256"` | CPU da task |
| `task_memory` | string | `"512"` | Memória da task |
| `desired_count` | number | `2` | Número de tasks |
| `launch_type` | string | `"FARGATE"` | Tipo de launch |
| `alb_internal` | bool | `false` | ALB interno |
| `health_check_path` | string | `"/"` | Path do health check |
| `log_retention_days` | number | `14` | Retenção de logs |

## 📤 Outputs

| Nome | Descrição |
|------|-----------|
| `ecs_cluster_id` | ID do cluster ECS |
| `ecs_cluster_name` | Nome do cluster ECS |
| `ecs_service_name` | Nome do serviço ECS |
| `alb_dns_name` | DNS name do ALB |
| `alb_arn` | ARN do ALB |
| `target_group_arn` | ARN do target group |
| `cloudwatch_log_group_name` | Nome do log group |

## 🔒 Segurança

### IAM Roles
- **Execution Role**: Permissões para pull de imagens e logs
- **Task Role**: Permissões específicas da aplicação

### Security Groups
- ALB aceita tráfego HTTP/HTTPS público
- ECS tasks aceitam tráfego apenas do ALB
- Egress irrestrito para tasks (pode ser customizado)

## 📊 Monitoramento

### CloudWatch Logs
- Log group: `/ecs/{prefix}-{app_name}-{environment}`
- Stream prefix: `ecs`
- Retenção configurável

### Métricas
- CPU e memória das tasks
- Request count e latency do ALB
- Target health

## 🚀 Deploy

### 1. Aplicar Terraform
```bash
terraform apply
```

### 2. Verificar Status
```bash
# Cluster
aws ecs describe-clusters --clusters nome-do-cluster

# Service
aws ecs describe-services --cluster nome-do-cluster --services nome-do-service

# Tasks
aws ecs list-tasks --cluster nome-do-cluster --service-name nome-do-service
```

### 3. Testar Aplicação
```bash
curl http://alb-dns-name
```

## 🔧 Troubleshooting

### Task não inicia
```bash
# Verificar eventos do serviço
aws ecs describe-services --cluster CLUSTER --services SERVICE

# Verificar logs
aws logs tail /ecs/app-logs --follow
```

### ALB não responde
```bash
# Verificar target health
aws elbv2 describe-target-health --target-group-arn TARGET_GROUP_ARN

# Verificar security groups
aws ec2 describe-security-groups --group-ids SG_ID
```

## 📚 Exemplos de Uso

### API REST
```hcl
module "api" {
  source = "./modules/ecs"

  app_name = "api-rest"
  app_image = "myapi:latest"
  app_port = 3000
  health_check_path = "/api/health"

  environment_variables = [
    { name = "NODE_ENV", value = "production" },
    { name = "PORT", value = "3000" }
  ]
}
```

### Frontend React
```hcl
module "frontend" {
  source = "./modules/ecs"

  app_name = "react-app"
  app_image = "myapp:latest"
  app_port = 80
  alb_internal = false

  task_cpu = "512"
  task_memory = "1024"
}
```

### Worker/Background Job
```hcl
module "worker" {
  source = "./modules/ecs"

  app_name = "background-worker"
  app_image = "worker:latest"
  desired_count = 1

  # Sem ALB para workers
  create_alb = false
}
```

---

**Última atualização**: Outubro 2024

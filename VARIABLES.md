# Documentação de Variáveis - ECS Fargate

## 📋 Visão Geral

Este documento detalha todas as variáveis disponíveis para configuração da infraestrutura ECS Fargate, organizadas por categoria.

## 🔧 Variáveis ECS Core

### Cluster Configuration
| Variável | Descrição | Tipo | Padrão | Obrigatória |
|----------|-----------|------|--------|-------------|
| `ecs_cluster_name` | Nome do cluster ECS | string | `"cloudfix-ecs"` | ✅ |
| `enable_container_insights` | Habilitar Container Insights | bool | `true` | ❌ |

### Application Configuration
| Variável | Descrição | Tipo | Padrão | Obrigatória |
|----------|-----------|------|--------|-------------|
| `app_name` | Nome da aplicação | string | `"app"` | ❌ |
| `app_image` | Imagem Docker da aplicação | string | `"nginx:latest"` | ✅ |
| `app_port` | Porta que a aplicação escuta | number | `80` | ❌ |

### Task Configuration
| Variável | Descrição | Tipo | Padrão | Valores Válidos |
|----------|-----------|------|--------|-----------------|
| `task_cpu` | CPU da task ECS | string | `"256"` | 256, 512, 1024, 2048, 4096 |
| `task_memory` | Memória da task ECS (MB) | string | `"512"` | 512, 1024, 2048, 4096, 8192 |
| `desired_count` | Número desejado de tasks | number | `2` | 1-100 |
| `assign_public_ip` | Atribuir IP público às tasks | bool | `false` | true/false |

## 🌐 Variáveis ALB (Application Load Balancer)

### Basic Configuration
| Variável | Descrição | Tipo | Padrão | Obrigatória |
|----------|-----------|------|--------|-------------|
| `alb_internal` | ALB interno (VPC only) | bool | `false` | ❌ |
| `alb_port` | Porta do ALB | number | `80` | ❌ |
| `alb_protocol` | Protocolo do ALB | string | `"HTTP"` | ❌ |

### Health Check Configuration
| Variável | Descrição | Tipo | Padrão | Range |
|----------|-----------|------|--------|-------|
| `health_check_path` | Caminho para health check | string | `"/"` | - |
| `health_check_matcher` | Códigos HTTP válidos | string | `"200"` | - |
| `health_check_interval` | Intervalo em segundos | number | `30` | 5-300 |
| `health_check_timeout` | Timeout em segundos | number | `5` | 2-120 |
| `healthy_threshold` | Checks sucessivos para healthy | number | `2` | 2-10 |
| `unhealthy_threshold` | Checks falhados para unhealthy | number | `2` | 2-10 |

## 📊 Variáveis CloudWatch

### Logging Configuration
| Variável | Descrição | Tipo | Padrão | Range |
|----------|-----------|------|--------|-------|
| `log_retention_days` | Retenção de logs (dias) | number | `14` | 1, 3, 5, 7, 14, 30, 60, 90, 120, 150, 180, 365, 400, 545, 731, 1827, 3653 |
| `log_group_name` | Nome do CloudWatch Log Group | string | `""` | Auto-gerado se vazio |

## 🗄️ Variáveis Database

### RDS Configuration
| Variável | Descrição | Tipo | Padrão | Obrigatória |
|----------|-----------|------|--------|-------------|
| `db_name` | Nome do database | string | - | ✅ |
| `db_username` | Usuário do database | string | - | ✅ |
| `db_password` | Senha do database | string | - | ✅ |
| `rds_instance_class` | Classe da instância RDS | string | - | ✅ |
| `rds_storage` | Storage inicial (GB) | number | `50` | ❌ |

### Valkey Configuration
| Variável | Descrição | Tipo | Padrão | Obrigatória |
|----------|-----------|------|--------|-------------|
| `valkey_node_type` | Tipo de instância Valkey | string | `"cache.t3.micro"` | ❌ |
| `valkey_num_nodes` | Número de nós Valkey | number | `1` | ❌ |
| `valkey_engine_version` | Versão do engine Valkey | string | `"8.0"` | ❌ |

## 🌐 Variáveis Network

### VPC Configuration
| Variável | Descrição | Tipo | Padrão | Obrigatória |
|----------|-----------|------|--------|-------------|
| `vpc_cidr` | CIDR block da VPC | string | `"10.0.0.0/16"` | ❌ |
| `num_azs` | Número de AZs | number | `2` | ❌ |

### Project Configuration
| Variável | Descrição | Tipo | Padrão | Obrigatória |
|----------|-----------|------|--------|-------------|
| `project_name` | Nome do projeto | string | - | ✅ |
| `prefix` | Prefixo para recursos | string | - | ✅ |
| `environment` | Ambiente (dev/hml/prod) | string | - | ✅ |

## 🏷️ Variáveis Tags

### Tags Configuration
| Variável | Descrição | Tipo | Padrão | Obrigatória |
|----------|-----------|------|--------|-------------|
| `tags` | Tags para todos os recursos | map(string) | `{}` | ❌ |

## 📝 Exemplos de Configuração

### Desenvolvimento
```hcl
# terraform.tfvars
ecs_cluster_name = "dev-cluster"
app_name = "minha-api"
app_image = "nginx:latest"
task_cpu = "256"
task_memory = "512"
desired_count = 1
alb_internal = true
log_retention_days = 7
enable_container_insights = false
```

### Produção
```hcl
# terraform.tfvars
ecs_cluster_name = "prod-cluster"
app_name = "minha-api"
app_image = "123456789012.dkr.ecr.us-east-1.amazonaws.com/minha-api:v1.0"
task_cpu = "1024"
task_memory = "2048"
desired_count = 3
alb_internal = false
health_check_path = "/health"
log_retention_days = 30
enable_container_insights = true
```

### API com Health Check Customizado
```hcl
# terraform.tfvars
app_name = "api-gateway"
app_port = 3000
health_check_path = "/api/health"
health_check_matcher = "200,201"
health_check_interval = 15
healthy_threshold = 3
```

### Configuração de Recursos
```hcl
# Aplicação pequena (desenvolvimento)
task_cpu = "256"    # 0.25 vCPU
task_memory = "512" # 512 MB
desired_count = 1

# Aplicação média (homologação)
task_cpu = "512"    # 0.5 vCPU
task_memory = "1024" # 1 GB
desired_count = 2

# Aplicação grande (produção)
task_cpu = "1024"   # 1 vCPU
task_memory = "2048" # 2 GB
desired_count = 3
```

## ⚠️ Considerações Importantes

### CPU e Memória Fargate
As combinações de CPU e memória devem seguir as especificações do Fargate:

| CPU (vCPU) | Memória Suportada |
|------------|-------------------|
| 0.25 (256) | 512MB, 1GB, 2GB |
| 0.5 (512) | 1GB, 2GB, 3GB, 4GB |
| 1 (1024) | 2GB, 3GB, 4GB, 5GB, 6GB, 7GB, 8GB |
| 2 (2048) | 4GB até 16GB (incrementos de 1GB) |
| 4 (4096) | 8GB até 30GB (incrementos de 1GB) |

### Health Checks
- O `health_check_path` deve retornar status HTTP 200 por padrão
- Ajuste `health_check_interval` e thresholds baseado na sua aplicação
- Para aplicações que demoram para inicializar, aumente os thresholds

### Logs e Monitoramento
- Retenção de logs impacta custos do CloudWatch
- Para desenvolvimento, use 7 dias
- Para produção, considere 30-90 dias
- Container Insights adiciona ~$1.50/mês por task

### Segurança
- Use `alb_internal = true` para aplicações internas
- `assign_public_ip = false` é recomendado para segurança
- Sempre use imagens específicas em produção (não `latest`)
- Configure variáveis de ambiente sensíveis via AWS Secrets Manager

### Custos
- Fargate cobra por vCPU-segundo e GB-segundo
- Tasks menores são mais econômicas para workloads variáveis
- Use Fargate Spot para economia de até 70% (workloads tolerantes a falhas)

---

**Última atualização**: Outubro 2024

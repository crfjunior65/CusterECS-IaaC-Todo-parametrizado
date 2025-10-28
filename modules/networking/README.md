# Módulo Networking

## 📋 Visão Geral

Este módulo cria uma infraestrutura de rede completa na AWS para suportar aplicações ECS Fargate, incluindo:

- **VPC** com DNS habilitado
- **Subnets** públicas e privadas em múltiplas AZs
- **Internet Gateway** para acesso à internet
- **NAT Gateway** para saída das subnets privadas
- **Route Tables** com roteamento adequado
- **Security Groups** para ECS, ALB e RDS

## 🏗️ Arquitetura de Rede

```
VPC (10.0.0.0/16)
├── Public Subnets (10.0.x.0/24)
│   ├── Internet Gateway
│   ├── NAT Gateway
│   └── ALB
├── ECS Private Subnets (10.0.10x.0/24)
│   ├── ECS Fargate Tasks
│   └── Route to NAT Gateway
└── RDS Private Subnets (10.0.20x.0/24)
    ├── RDS PostgreSQL
    ├── Valkey Cache
    └── Route to NAT Gateway
```

## 📦 Recursos Criados

### Network Resources
- `aws_vpc` - VPC principal
- `aws_subnet` - Subnets públicas, ECS privadas, RDS privadas
- `aws_internet_gateway` - Gateway para internet
- `aws_nat_gateway` - Gateway NAT para subnets privadas
- `aws_eip` - Elastic IP para NAT Gateway

### Routing Resources
- `aws_route_table` - Tabelas de rota
- `aws_route_table_association` - Associações subnet-route

### Security Resources
- `aws_security_group` - Security groups para ALB, ECS, RDS

## 🔧 Configuração

### Exemplo Básico
```hcl
module "networking" {
  source = "./modules/networking"

  vpc_cidr = "10.0.0.0/16"

  subnets_public = [
    "10.0.1.0/24",
    "10.0.2.0/24"
  ]

  ecs_private_subnets = [
    "10.0.101.0/24",
    "10.0.102.0/24"
  ]

  rds_private_subnets = [
    "10.0.201.0/24",
    "10.0.202.0/24"
  ]

  availability_zones = ["us-east-1a", "us-east-1b"]

  prefix = "cloudfix"
  environment = "hml"

  tags = {
    Environment = "homolog"
    Project     = "cloudfix"
  }
}
```

## 📊 Variáveis

### Obrigatórias
| Nome | Tipo | Descrição |
|------|------|-----------|
| `vpc_cidr` | string | CIDR block da VPC |
| `subnets_public` | list(string) | CIDRs das subnets públicas |
| `ecs_private_subnets` | list(string) | CIDRs das subnets ECS privadas |
| `rds_private_subnets` | list(string) | CIDRs das subnets RDS privadas |
| `availability_zones` | list(string) | Lista de AZs |
| `prefix` | string | Prefixo para recursos |
| `environment` | string | Nome do ambiente |

## 📤 Outputs

### Network Outputs
| Nome | Descrição |
|------|-----------|
| `vpc_id` | ID da VPC |
| `public_subnet_ids` | IDs das subnets públicas |
| `ecs_private_subnet_ids` | IDs das subnets ECS privadas |
| `rds_private_subnet_ids` | IDs das subnets RDS privadas |
| `alb_security_group_id` | ID do SG do ALB |
| `ecs_security_group_id` | ID do SG do ECS |
| `rds_security_group_id` | ID do SG do RDS |

## 🔒 Security Groups

### ALB Security Group
- **Inbound**: Port 80/443 from 0.0.0.0/0
- **Outbound**: All traffic

### ECS Security Group
- **Inbound**: All traffic from ALB SG
- **Outbound**: All traffic

### RDS Security Group
- **Inbound**: Port 5432 from ECS SG, Port 6379 from ECS SG
- **Outbound**: All traffic

---

**Última atualização**: Outubro 2024

# Módulo Valkey

## 📋 Visão Geral

Este módulo cria uma infraestrutura de cache **Valkey** (fork open-source do Redis) na AWS usando ElastiCache, incluindo:

- **ElastiCache Replication Group** com Valkey engine
- **Subnet Group** para isolamento de rede
- **Security Group** para controle de acesso
- **Configuração Multi-AZ** para alta disponibilidade

## 🔍 O que é Valkey?

**Valkey** é um fork open-source do Redis mantido pela Linux Foundation:
- **100% compatível** com Redis API
- **Licença BSD 3-Clause** (totalmente open-source)
- **Mesma performance** do Redis
- **Governança transparente** pela Linux Foundation

## 🏗️ Arquitetura

```
ECS Tasks → Security Group → Valkey Cluster
                              ├── Primary Node (Read/Write)
                              └── Replica Node (Read Only)
```

## 📦 Recursos Criados

### ElastiCache Resources
- `aws_elasticache_replication_group` - Cluster Valkey principal
- `aws_elasticache_subnet_group` - Grupo de subnets

### Security Resources
- `aws_security_group` - Controle de acesso ao Valkey

## 🔧 Configuração

### Exemplo Básico
```hcl
module "valkey" {
  source = "./modules/valkey"

  prefix                = "pbet"
  project_name          = "plataforma-bet"
  vpc_id                = "vpc-12345"
  private_subnet_ids    = ["subnet-12345", "subnet-67890"]
  ecs_security_group_id = "sg-12345"
  environment           = "hml"

  node_type       = "cache.t3.micro"
  num_cache_nodes = 2
  engine_version  = "8.0"

  tags = {
    Environment = "homolog"
    Project     = "pbet"
  }
}
```

### Configuração Avançada
```hcl
module "valkey" {
  source = "./modules/valkey"

  # Project Configuration
  prefix       = "prod"
  project_name = "plataforma-bet"
  environment  = "prod"

  # Network Configuration
  vpc_id                = var.vpc_id
  private_subnet_ids    = var.rds_private_subnet_ids
  ecs_security_group_id = var.ecs_security_group_id

  # Valkey Configuration
  node_type       = "cache.r6g.large"
  num_cache_nodes = 3
  engine_version  = "8.0"

  # Advanced Settings
  port                     = 6379
  parameter_group_name     = "default.valkey8"
  at_rest_encryption_enabled = true
  transit_encryption_enabled = true

  # Maintenance
  maintenance_window       = "sun:03:00-sun:04:00"
  snapshot_retention_limit = 7
  snapshot_window         = "02:00-03:00"

  tags = {
    Environment = "production"
    Project     = "pbet"
    Backup      = "required"
  }
}
```

## 📊 Variáveis

### Obrigatórias
| Nome | Tipo | Descrição |
|------|------|-----------|
| `prefix` | string | Prefixo para recursos |
| `project_name` | string | Nome do projeto |
| `vpc_id` | string | ID da VPC |
| `private_subnet_ids` | list(string) | IDs das subnets privadas |
| `ecs_security_group_id` | string | ID do SG do ECS |
| `environment` | string | Nome do ambiente |

### Opcionais
| Nome | Tipo | Padrão | Descrição |
|------|------|--------|-----------|
| `node_type` | string | `"cache.t3.micro"` | Tipo de instância |
| `num_cache_nodes` | number | `2` | Número de nós |
| `engine_version` | string | `"8.0"` | Versão do Valkey |
| `port` | number | `6379` | Porta do Valkey |
| `parameter_group_name` | string | `"default.valkey8"` | Parameter group |
| `at_rest_encryption_enabled` | bool | `true` | Criptografia em repouso |
| `transit_encryption_enabled` | bool | `false` | Criptografia em trânsito |

## 📤 Outputs

| Nome | Descrição |
|------|-----------|
| `valkey_endpoint` | Endpoint primário do Valkey |
| `valkey_port` | Porta do Valkey |
| `valkey_reader_endpoint` | Endpoint de leitura |
| `replication_group_id` | ID do replication group |
| `security_group_id` | ID do security group |

## 🔒 Segurança

### Network Security
- **Subnets Privadas**: Valkey isolado em subnets privadas
- **Security Group**: Acesso apenas do ECS na porta 6379
- **VPC Only**: Sem acesso público à internet

### Encryption
```hcl
# Criptografia em repouso (recomendado)
at_rest_encryption_enabled = true

# Criptografia em trânsito (opcional)
transit_encryption_enabled = true
```

### Access Control
```hcl
# Security Group Rules
ingress {
  from_port       = 6379
  to_port         = 6379
  protocol        = "tcp"
  security_groups = [var.ecs_security_group_id]
}
```

## 📊 Tipos de Instância

### Desenvolvimento
| Tipo | vCPU | Memória | Rede | Custo/mês* |
|------|------|---------|------|------------|
| `cache.t3.micro` | 2 | 0.5 GB | Baixa | ~$15 |
| `cache.t3.small` | 2 | 1.37 GB | Baixa | ~$30 |

### Produção
| Tipo | vCPU | Memória | Rede | Custo/mês* |
|------|------|---------|------|------------|
| `cache.r6g.large` | 2 | 12.32 GB | Alta | ~$120 |
| `cache.r6g.xlarge` | 4 | 25.05 GB | Alta | ~$240 |

*Preços aproximados para us-east-1

## 🚀 Uso da Aplicação

### Conectividade
```bash
# Variáveis de ambiente no ECS
REDIS_HOST=valkey-endpoint
REDIS_PORT=6379
```

### Exemplo Python
```python
import redis

# Conectar ao Valkey
client = redis.Redis(
    host='valkey-endpoint',
    port=6379,
    decode_responses=True
)

# Operações básicas
client.set('key', 'value')
value = client.get('key')

# Cache de sessão
client.setex('session:123', 3600, 'user_data')
```

### Exemplo Node.js
```javascript
const redis = require('redis');

const client = redis.createClient({
  host: process.env.REDIS_HOST,
  port: process.env.REDIS_PORT
});

// Cache de dados
await client.set('user:123', JSON.stringify(userData), 'EX', 3600);
const cached = await client.get('user:123');
```

## 📊 Monitoramento

### CloudWatch Metrics
- **CPUUtilization**: Uso de CPU dos nós
- **DatabaseMemoryUsagePercentage**: Uso de memória
- **CacheHitRate**: Taxa de acerto do cache
- **CurrConnections**: Conexões ativas
- **Evictions**: Número de evictions

### Alertas Recomendados
```hcl
# CPU > 80%
# Memory > 85%
# Cache Hit Rate < 90%
# Connections > limite
```

## 🔧 Troubleshooting

### Conectividade
```bash
# Testar conectividade do ECS
aws ecs run-task --cluster CLUSTER --task-definition TASK --overrides '{
  "containerOverrides": [{
    "name": "container",
    "command": ["redis-cli", "-h", "valkey-endpoint", "ping"]
  }]
}'
```

### Performance
```bash
# Verificar métricas
aws cloudwatch get-metric-statistics \
  --namespace AWS/ElastiCache \
  --metric-name CPUUtilization \
  --dimensions Name=CacheClusterId,Value=valkey-cluster-001
```

### Logs
```bash
# Verificar logs do ElastiCache
aws logs describe-log-groups --log-group-name-prefix /aws/elasticache
```

## 📚 Casos de Uso

### 1. Cache de Sessão
```python
# Armazenar sessão de usuário
session_data = {
    'user_id': 123,
    'permissions': ['read', 'write'],
    'expires_at': time.time() + 3600
}
client.setex(f'session:{session_id}', 3600, json.dumps(session_data))
```

### 2. Cache de Consultas
```python
# Cache de resultado de query
def get_user_data(user_id):
    cache_key = f'user:{user_id}'
    cached = client.get(cache_key)

    if cached:
        return json.loads(cached)

    # Buscar no banco
    user_data = db.query('SELECT * FROM users WHERE id = %s', user_id)

    # Cachear por 1 hora
    client.setex(cache_key, 3600, json.dumps(user_data))
    return user_data
```

### 3. Rate Limiting
```python
def check_rate_limit(user_id, limit=100):
    key = f'rate_limit:{user_id}:{int(time.time() // 3600)}'
    current = client.incr(key)

    if current == 1:
        client.expire(key, 3600)

    return current <= limit
```

## 🔄 Backup e Recuperação

### Snapshots Automáticos
```hcl
# Configuração de backup
snapshot_retention_limit = 7
snapshot_window         = "02:00-03:00"
```

### Restore Manual
```bash
# Criar snapshot manual
aws elasticache create-snapshot \
  --replication-group-id valkey-cluster \
  --snapshot-name manual-backup-$(date +%Y%m%d)

# Restaurar de snapshot
aws elasticache create-replication-group \
  --replication-group-id new-cluster \
  --snapshot-name backup-snapshot
```

---

**Última atualização**: Outubro 2024

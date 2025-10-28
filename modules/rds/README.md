<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | 6.16.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_db_instance.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_instance) | resource |
| [aws_db_subnet_group.main](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/db_subnet_group) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_allocated_storage"></a> [allocated\_storage](#input\_allocated\_storage) | Espaço em disco alocado para o RDS (GB) | `number` | `20` | no |
| <a name="input_backup_retention_period"></a> [backup\_retention\_period](#input\_backup\_retention\_period) | Período de retenção dos backups (dias) | `number` | `0` | no |
| <a name="input_db_name"></a> [db\_name](#input\_db\_name) | Nome do banco de dados | `string` | `"cloudfix"` | no |
| <a name="input_db_password"></a> [db\_password](#input\_db\_password) | Senha do banco de dados | `string` | `"cloudfix_password"` | no |
| <a name="input_db_username"></a> [db\_username](#input\_db\_username) | Nome de usuário do banco de dados | `string` | `"cloudfix"` | no |
| <a name="input_ecs_cluster_security_group_id"></a> [ecs\_cluster\_security\_group\_id](#input\_ecs\_cluster\_security\_group\_id) | Security group ID do cluster ECS para permitir acesso ao RDS | `string` | n/a | yes |
| <a name="input_environment"></a> [environment](#input\_environment) | Environment name (e.g., dev, prod, hml) | `string` | n/a | yes |
| <a name="input_instance_class"></a> [instance\_class](#input\_instance\_class) | Classe da instância do RDS | `string` | `"db.t3.micro"` | no |
| <a name="input_max_allocated_storage"></a> [max\_allocated\_storage](#input\_max\_allocated\_storage) | Espaço máximo em disco que o RDS pode crescer (GB) | `number` | `100` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefixo do projeto (herdado da raiz) | `string` | `""` | no |
| <a name="input_security_group_ids"></a> [security\_group\_ids](#input\_security\_group\_ids) | IDs dos security groups para o RDS | `list(string)` | n/a | yes |
| <a name="input_skip_final_snapshot"></a> [skip\_final\_snapshot](#input\_skip\_final\_snapshot) | Pular snapshot final ao destruir o banco | `bool` | `false` | no |
| <a name="input_subnet_ids"></a> [subnet\_ids](#input\_subnet\_ids) | IDs das subnets onde o RDS será criado | `list(string)` | n/a | yes |
| <a name="input_tags"></a> [tags](#input\_tags) | Tags comuns para todos os recursos | `map(string)` | `{}` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | ID da VPC onde o RDS será criado | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_db_instance_arn"></a> [db\_instance\_arn](#output\_db\_instance\_arn) | ARN da instância do RDS |
| <a name="output_db_instance_endpoint"></a> [db\_instance\_endpoint](#output\_db\_instance\_endpoint) | Endpoint da instância do RDS |
| <a name="output_db_instance_id"></a> [db\_instance\_id](#output\_db\_instance\_id) | ID da instância do RDS |
| <a name="output_db_instance_name"></a> [db\_instance\_name](#output\_db\_instance\_name) | Nome do banco de dados |
| <a name="output_db_instance_password"></a> [db\_instance\_password](#output\_db\_instance\_password) | Senha do banco de dados |
| <a name="output_db_instance_port"></a> [db\_instance\_port](#output\_db\_instance\_port) | Porta da instância do RDS |
| <a name="output_db_instance_username"></a> [db\_instance\_username](#output\_db\_instance\_username) | Nome de usuário do banco de dados |
<!-- END_TF_DOCS -->

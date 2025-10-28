#!/bin/bash

# Backup of original DwnTerraform.sh
#!/bin/bash

# Script para executar terraform destroy com medição de tempo
set -e

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "🕒 Iniciando Procedimentos do Terraform em: ${TIMESTAMP}"

echo "🚀 Iniciando Terraform..."
start_time=$(date +%s)

# Inicializando Terraform
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "🕒 Iniciando Terraform Destroy em: ${TIMESTAMP}"
# Remover addons EKS primeiro (evita travamento)
#aws eks delete-addon --cluster-name pbet-cluster --addon-name amazon-cloudwatch-observability --region us-east-1
#aws eks delete-addon --cluster-name pbet-cluster --addon-name aws-load-balancer-controller --region us-east-1
terraform destroy -auto-approve

# Remover estado do Terraform
#rm -rf .terraform*
[ -e .terraform* ] && rm -rf .terraform* 2>/dev/null
#rm terraform.tfstate*
[ -e terraform.tfstate ] && rm -rf terraform.tfstate 2>/dev/null
#rm plan.out
[ -e plan.out ] && rm -rf plan.out 2>/dev/null

end_time=$(date +%s)
execution_time=$((end_time - start_time))

# Converter para formato legível
hours=$((execution_time / 3600))
minutes=$(( (execution_time % 3600) / 60 ))
seconds=$((execution_time % 60))

echo "✅ Terraform Destroy concluído!"
echo "⏱️  Tempo total de execução: ${hours}h ${minutes}m ${seconds}s"
echo "⏱️  Tempo em segundos: ${execution_time}s"

# Salvar em arquivo de log
echo "$(date): Terraform iDestroy executado em ${execution_time} segundos" >> terraform_times.log

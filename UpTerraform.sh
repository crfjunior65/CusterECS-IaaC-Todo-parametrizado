#!/bin/bash

# Backup of original UpTerraform.sh
#!/bin/bash

# Script para executar terraform apply com medição de tempo
set -e

TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "🕒 Iniciando Procedimentos do Terraform em: ${TIMESTAMP}"

echo "🚀 Iniciando Terraform..."
start_time=$(date +%s)

# Inicializando Terraform
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "🕒 Iniciando Terraform Init em: ${TIMESTAMP}"
terraform init -reconfigure
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "🕒 Iniciando Terraform Validate em: ${TIMESTAMP}"
terraform validate
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "🕒 Iniciando Terraform Farmat em: ${TIMESTAMP}"
terraform fmt --recursive

# Executar terraform apply
TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")
echo "🕒 Iniciando Terraform Apply em: ${TIMESTAMP}"
# 2. Aplicar infraestrutura base (sem dashboard)
#terraform apply -target=module.vpc -target=module.rds -target=module.eks -auto-approve

# 3. Aguardar EKS estar pronto (5-10 minutos)
#aws eks update-kubeconfig --region us-east-1 --name cloudfix-cluster

# 4. Instalar Load Balancer Controller
#terraform apply -target=helm_release.aws_load_balancer_controller -auto-approve

# 5. Instalar CloudWatch Observability
#aws eks create-addon --cluster-name cloudfix-cluster --addon-name amazon-cloudwatch-observability --region us-east-1

# 6. DEPLOYMENTS DE APLICAÇÃO (AQUI!)
#kubectl apply -f k8s/  # Se tiver manifests K8s
# OU
#terraform apply -target=kubernetes_deployment.app -auto-approve  # Se estiver no Terraform

# Aguardar 3-5 minutos para métricas aparecerem
#sleep 250

# 7. Aplicar dashboard
#terraform apply -target=aws_cloudwatch_dashboard.cloudfix_dashboard_teste -auto-approve

# 8. Aplicar resto (se houver)
terraform apply -auto-approve

# Instalar CloudWatch Observability
#aws eks create-addon --cluster-name cloudfix-cluster --addon-name amazon-cloudwatch-observability --region us-east-1
# DEPLOYMENTS DE APLICAÇÃO (AQUI!)
# . Aguardar EKS estar pronto (5-10 minutos)
#aws eks update-kubeconfig --region us-east-1 --name cloudfix-cluster

# Instalar CloudWatch Agent
#kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cloudwatch-namespace.yaml

#kubectl apply -f https://raw.githubusercontent.com/aws-samples/amazon-cloudwatch-container-insights/latest/k8s-deployment-manifest-templates/deployment-mode/daemonset/container-insights-monitoring/cwagent/cwagent-daemonset.yaml

#kubectl apply -f k8s/  # Se tiver manifests K8s
# OU
#terraform apply -target=kubernetes_deployment.app -auto-approve  # Se estiver no Terraform

end_time=$(date +%s)
execution_time=$((end_time - start_time))

# Converter para formato legível
hours=$((execution_time / 3600))
minutes=$(( (execution_time % 3600) / 60 ))
seconds=$((execution_time % 60))

echo "✅ Terraform Apply concluído!"
echo "⏱️  Tempo total de execução: ${hours}h ${minutes}m ${seconds}s"
echo "⏱️  Tempo em segundos: ${execution_time}s"

# Salvar em arquivo de log
echo "$(date): Terraform apply executado em ${execution_time} segundos" >> terraform_times.log
sleep 5

#clear

#echo "### **4. VERIFICAÇÕES FINAIS**"
#echo "bash"
#echo "# Verificar cluster"
#echo ""
#echo "Conectando no Cluster EKS:"
#echo "✅ aws eks update-kubeconfig --region us-east-1 --name cloudfix-cluster ✅"
#echo ""
#echo "kubectl get nodes"
#echo ""
#echo "# Verificar addons"
#echo "aws eks describe-addon --cluster-name cloudfix-cluster --addon-name amazon-cloudwatch-observability --region us-east-1"
#echo ""
#echo "# Verificar métricas (após 5 minutos)"
#echo "aws cloudwatch list-metrics --namespace ContainerInsights --region us-east-1 | grep cloudfix-cluster"
#echo ""
#echo "# Verificar dashboard"
#echo "aws cloudwatch get-dashboard --dashboard-name cloudfix-dashboard-funcional-completo --region us-east-1"
#echo ""
#echo "### **5. ORDEM CRÍTICA DE DEPENDÊNCIAS**"
#echo "1. VPC → RDS → EKS (base)"
#echo "2. Load Balancer Controller (Helm)"
#echo "3. CloudWatch Addon (AWS CLI)"
#echo "4. Dashboard (após métricas estarem disponíveis)"
#echo ""
#echo "⚠️ NUNCA pule a ordem ou aplique tudo junto na primeira vez!"

# Solicitar permissao para startar os Manifestos de Configuração
#read -p "Deseja aplicar os manifestos de configuração do Kubernetes agora? (s/n): " apply_manifests
#if [[ "$apply_manifests" == "s" || "$apply_manifests" == "S" ]]; then
#    #aws eks update-kubeconfig --region us-east-1 --name cloudfix-cluster
#    aws eks update-kubeconfig --region us-east-1 --name $(terraform output -raw k8s_name)
#    # Aplicar os manifestos de configuração do Kubernetes
#    echo "Aplicando manifestos de configuração do Kubernetes..."
#    kubectl apply -f k8s-manifests/
#    echo "Manifestos aplicados com sucesso."
#else
#    echo "Pule a aplicação dos manifestos de configuração do Kubernetes."
#fi

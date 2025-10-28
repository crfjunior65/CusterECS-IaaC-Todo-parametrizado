# GitHub Actions - Configuração de Secrets

Este documento descreve os secrets necessários para o pipeline CI/CD funcionar corretamente com AWS ECR e EKS.

## 🔐 Secrets Obrigatórios

Configure os seguintes secrets no GitHub (Settings > Secrets and variables > Actions):

### AWS Credentials
```
AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY
```

### Valores de Exemplo (substitua pelos seus valores reais):
- **AWS_ACCESS_KEY_ID**: `AKIAIOSFODNN7EXAMPLE`
- **AWS_SECRET_ACCESS_KEY**: `wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY`

## 🏗️ Variáveis de Ambiente Configuradas no Workflow

As seguintes variáveis estão definidas no arquivo `main.yml`:

```yaml
env:
  AWS_REGION: us-east-1
  ECR_REPOSITORY: backoffice/pbet-bko-api-back-stg
  EKS_CLUSTER_NAME: pbet-cluster
```

### Para alterar esses valores:
1. Edite o arquivo `.github/workflows/main.yml`
2. Modifique a seção `env:` conforme necessário

## 🚀 Como o Pipeline Funciona

### 1. **Build e Push para ECR**
- Faz checkout do código
- Configura credenciais AWS
- Faz login no ECR
- Constrói a imagem Docker
- Faz push para o ECR com múltiplas tags

### 2. **Deploy no EKS**
- Configura kubectl
- Conecta ao cluster EKS
- Aplica ConfigMap e Secret
- Atualiza deployment com nova imagem
- Monitora o rollout

## 🔧 Configuração Inicial Necessária

### 1. **Criar repositório ECR**
```bash
aws ecr create-repository --repository-name backoffice/pbet-bko-api-back-stg --region us-east-1
```

### 2. **Configurar cluster EKS**
Certifique-se de que o cluster `pbet-cluster` existe e está acessível.

### 3. **Namespace Kubernetes**
```bash
kubectl create namespace backoffice
```

## 🎯 Triggers do Pipeline

O pipeline será executado quando:
- Push na branch `main` (deploy em production)
- Push na branch `devops` (deploy em staging)
- Pull Request para `main` (apenas build, sem deploy)

## 📋 Tags de Imagem Geradas

O pipeline cria as seguintes tags automaticamente:
- `latest` (apenas para branch main)
- `v{run_number}` (número sequencial do GitHub Actions)
- `{branch}-{sha}` (branch + hash do commit)
- `{branch}` (nome da branch)

## 🔍 Monitoramento

O pipeline inclui verificações de:
- Status do cluster
- Status do deployment
- Pods em execução
- Logs de rollout

## ⚠️ Importante

1. **Permissões AWS**: O usuário AWS deve ter permissões para:
   - ECR (push/pull de imagens)
   - EKS (acesso ao cluster)
   - IAM (assumir roles se necessário)

2. **Arquivos Kubernetes**: Certifique-se de que os arquivos em `.deploy/eks/` estão corretos:
   - `pbet-bko-configmap.yml`
   - `pbet-bko-secret.yml`
   - `pbet-bko-deployment.yml`

3. **Ambientes**: Configure os ambientes `production` e `staging` no GitHub se quiser aprovação manual para deploys.

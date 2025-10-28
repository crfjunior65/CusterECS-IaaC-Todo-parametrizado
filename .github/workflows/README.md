# 🔄 GitHub Actions Workflows

## 📋 Workflows Disponíveis

### 🚀 Deploy Infrastructure (`deploy-infra.yml`)
**Propósito**: Deploy e atualização da infraestrutura CloudFix

**Triggers**:
- **Manual**: Via workflow_dispatch com seleção de ambiente
- **Automático**: Push para branch `main` (deploy em hml)

**Funcionalidades**:
- ✅ Validação de código Terraform
- ✅ Security scan com tfsec
- ✅ Plan antes do deploy
- ✅ Deploy com aprovação manual
- ✅ Outputs detalhados

**Como usar**:
1. Acesse Actions → Deploy Infrastructure
2. Selecione o ambiente (dev/hml/prod)
3. Digite "deploy" para confirmar
4. Aguarde aprovação (se necessário)

### 🗑️ Destroy Infrastructure (`destroy-infra.yml`)
**Propósito**: Destruição segura da infraestrutura

**Triggers**:
- **Apenas Manual**: Via workflow_dispatch

**Funcionalidades**:
- ⚠️ Validação rigorosa de confirmação
- ⚠️ Proteção contra destruição de produção
- ✅ Plan destroy antes da execução
- ✅ Aprovação manual obrigatória
- ✅ Logs de auditoria completos

**Como usar**:
1. Acesse Actions → Destroy Infrastructure
2. Selecione ambiente (dev/hml apenas)
3. Digite "DESTROY" (case sensitive)
4. Informe o motivo da destruição
5. Aguarde aprovação obrigatória

## 🔐 Configuração de Secrets

Configure os seguintes secrets no repositório:

```
AWS_ACCESS_KEY_ID     # Access Key da AWS
AWS_SECRET_ACCESS_KEY # Secret Key da AWS
```

## 🛡️ Proteções de Segurança

### Deploy Workflow
- ✅ Validação de formato Terraform
- ✅ Security scan automático
- ✅ Plan obrigatório antes do apply
- ✅ Aprovação manual para produção

### Destroy Workflow
- ⚠️ Confirmação "DESTROY" obrigatória
- ⚠️ Produção bloqueada por código
- ⚠️ Motivo obrigatório para auditoria
- ⚠️ Aprovação manual sempre necessária
- ⚠️ Delay de 10 segundos antes da destruição

## 📊 Environments

Configure os seguintes environments no GitHub:

### Para Deploy
- `dev` - Desenvolvimento
- `hml` - Homologação  
- `prod` - Produção (com aprovação obrigatória)

### Para Destroy
- `dev-destroy` - Destruição desenvolvimento
- `hml-destroy` - Destruição homologação

## 🔄 Fluxo de Trabalho

### Desenvolvimento
```
1. Push código → Auto deploy hml
2. Teste em hml
3. Manual deploy prod (com aprovação)
```

### Limpeza
```
1. Manual destroy dev/hml
2. Confirmação obrigatória
3. Auditoria automática
```

## 📝 Logs e Auditoria

Todos os workflows geram:
- ✅ Step summaries detalhados
- ✅ Logs de auditoria
- ✅ Outputs da infraestrutura
- ✅ Timestamps de execução

## 🚨 Troubleshooting

### Deploy falha
1. Verificar secrets AWS
2. Verificar sintaxe Terraform
3. Verificar permissões IAM
4. Consultar logs detalhados

### Destroy falha
1. Verificar dependências de recursos
2. Verificar state lock
3. Executar destroy manual se necessário
4. Contatar equipe de infraestrutura

---

**Última atualização**: Outubro 2024

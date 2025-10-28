## Contribuições

Obrigado por contribuir com este repositório. Aqui estão algumas orientações rápidas para abrir Issues e Pull Requests.

### Abrindo uma Issue

- Use os templates pré-definidos (bug, feature, infra) para fornecer contexto completo.
- Para bugs inclua `terraform plan`/`kubectl` logs quando possível.

### Abrindo um Pull Request

- Preencha o template de PR e marque o tipo de mudança.
- Antes de pedir revisão, execute:
  - `terraform fmt -recursive` nas pastas de terraform
  - `terraform init -backend=false` e `terraform validate` no diretório afetado
  - `terraform plan -var-file=terraform-aws/terraform.tfvars` (ou equivalente) e anexe o output
  - Para alterações em Kubernetes, valide manifests com `kubectl apply --dry-run=client -f <file>`

### Checklist do Reviewer

- [ ] As mudanças estão descritas e justificadas?
- [ ] Não há segredos hard-coded?
- [ ] `terraform plan` foi executado e o impacto é aceitável?
- [ ] Risco/rollback e runbook cobertos em mudanças de infra?

Se quiser, podemos adicionar templates adicionais (ex.: SECURITY.md, SUPPORT.md) ou integrar com actions de CI que validem `terraform fmt`/`validate` automaticamente.

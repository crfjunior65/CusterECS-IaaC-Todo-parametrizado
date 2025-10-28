---
name: Solicitação Infra / Terraform
about: Use para mudanças em Terraform, módulos, deploy infra ou runbooks
title: '[INFRA] '
labels: infrastructure
assignees: ''
---

# Resumo da mudança

Explique o que será alterado na infraestrutura (módulos, state, backend).

# Checklist pré-aprovação

- [ ] `terraform fmt` aplicado
- [ ] `terraform validate` executado
- [ ] `terraform plan` anexado ou link para CI
- [ ] Alterações em state/ backend descritas (ex.: mudança de S3/Dynamo)
- [ ] Migração/Runbook detalhado (se houver alterações de impacto)

# Riscos e rollback

Descreva riscos conhecidos, impacto e como reverter.

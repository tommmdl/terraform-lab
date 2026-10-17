# Validação — 17/10/2026

[English](validation.en.md)

**22 verificações locais aprovadas**, concluídas às 19:08:59 no fuso America/Sao_Paulo (22:08:59 UTC). Execução real em Linux/WSL, com Terraform 1.14.9, provider `kreuzwerker/docker` 4.6.0 e Docker Engine 29.1.3. Execução técnica realizada pelo assistente com autorização do proprietário.

## Ciclo observado

| Etapa | Resultado |
| --- | --- |
| fmt e validate | Aprovados |
| Porta inválida (80) | Rejeitada antes de apply |
| Plano inicial | 6 criações |
| Apply | Rede, volume, imagens e containers provisionados |
| API | Readiness 200 e criação de nota 201 |
| Segundo plan | Exit 0, nenhuma alteração |
| Substituição de API e banco | Apenas os 2 containers substituídos; nota preservada |
| Drift: API parada fora do Terraform | Plan exit 2; substituição da API planejada |
| Reconciliação | API pronta novamente; nota preservada |
| Plano após reconciliação | Exit 0, nenhuma alteração |
| Plano de destroy | 6 exclusões |
| Destroy | State vazio; containers, rede e volume removidos |
| Segredo no state | Conteúdo da senha ausente do state final e backup |

O volume foi removido ao final do teste. Nenhuma aplicação Terraform ficou rodando na porta 8002. Imagens permaneceram no cache devido a `keep_locally = true`; state local vazio, backups, binário e arquivos de teste ficaram em `.local/`, fora do Git. Os demais laboratórios não foram alterados.

## Evidências

- [Checks e ações dos planos, sem state bruto](../evidence/lifecycle-results.json)
- [Versões utilizadas](../evidence/runtime.json)
- [Validação aprovada no GitHub Actions](https://github.com/tommmdl/terraform-lab/actions/runs/39073809062)
- [Etapas e metadados do CI](../evidence/ci-run.json)
- [Código do verificador](../scripts/verify.py)

O CI executou fmt, init com backend desabilitado/lockfile readonly e validate. Não aplicou infraestrutura. Planos, logs locais completos e state não foram publicados porque podem conter metadados do ambiente. Os arquivos de evidência foram revisados para excluir a senha local.

## Limites

Persistência testada por substituição dos containers, sem perda/restauração do volume. Drift testado por parada da API, não por todos os tipos de alteração possíveis. O provider optou por substituir a API parada para reconciliar a configuração. O teste de ausência de senha no state verifica este arquivo específico, sem afirmar que todo state Terraform é livre de segredos. Sem cloud, custos cloud, backend remoto, backup/restauração, teste de carga ou deploy em produção. A interface usa o artefato já testado nos laboratórios anteriores; aqui a verificação da aplicação foi via API.

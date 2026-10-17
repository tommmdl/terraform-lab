# Sobre o histórico / About the history

Em 17/10/2026, as mensagens dos commits da branch `main` foram encurtadas para facilitar a leitura. Essa etapa preservou os arquivos de cada commit, seus autores e suas datas. Depois vieram as alterações de documentação. Os backups do histórico anterior foram salvos localmente antes do force push.

Os relatórios, logs e metadados de imagens continuam mostrando os SHAs usados nas execuções originais. Eles são registros históricos e não foram alterados para aparentar novas execuções. A tabela relaciona esses commits com os commits equivalentes do histórico revisado. O pipeline passa a usar uma revisão acessível do histórico novo em `source.json`.

On 2026-10-17, commit messages on `main` were shortened for readability. This step preserved each commit's files, authors and dates; documentation edits came afterward. Local backups were saved before the force push.

Reports, logs and image metadata still show the SHAs used by their original runs. They are historical records, not rewritten test results. The table maps those commits to their equivalents in the revised history. The pipeline's `source.json` uses an accessible revision from the new history.

| SHA anterior / Previous SHA | SHA equivalente / Equivalent SHA | Mensagem / Message |
| --- | --- | --- |
| `26c3738bbe25161a77251ed76998dae9f3e7eaff` | `af5344dcfa42b939c332d646bd3db6634aa670a9` | Cria a infraestrutura Docker com Terraform |
| `514f7285f49a02aa2b71eee710af2714e0825465` | `9933fd5d9ca6be617b4e168086b4beb3f360efa8` | Registra os testes de criação, drift e limpeza |

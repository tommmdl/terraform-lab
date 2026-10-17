# Terraform: criar, mudar e desfazer um ambiente

[English](README.en.md) · Português

E se a rede, o banco e os containers fossem descritos em arquivos que você pudesse revisar antes de executar? Este laboratório usa Terraform para montar o ambiente da aplicação de notas e acompanhar suas mudanças ao longo do tempo.

O projeto roda no Docker local, sem conta cloud ou recursos de cloud paga. Isso deixa espaço para praticar módulos, state e drift antes de levar os mesmos conceitos para outro ambiente.

[![Terraform](https://github.com/tommmdl/terraform-lab/actions/workflows/validate.yml/badge.svg)](https://github.com/tommmdl/terraform-lab/actions/workflows/validate.yml)

## Para começar

Linux/WSL, Docker, Bash, Python 3, curl e porta 8002 livre. O script pode instalar Terraform 1.14.9 em Linux x86_64.

Na raiz deste repositório:

```bash
bash scripts/prepare.sh
bash scripts/tf.sh init -input=false
bash scripts/tf.sh plan -out=.local/create.tfplan
bash scripts/tf.sh show .local/create.tfplan
bash scripts/tf.sh apply .local/create.tfplan
```

Revise o plano antes do apply. Quando terminar, a aplicação fica em http://localhost:8002.

## Experimente

1. Confira os seis recursos no plano antes de criar o ambiente.
2. Rode outro plan depois do apply e procure mudanças pendentes.
3. Substitua os containers e confira se as notas continuam no banco.
4. Pare a API fora do Terraform e veja como ele detecta e corrige o drift.

## O que já foi testado

As 22 verificações locais passaram, incluindo criação, plano sem mudanças, persistência, correção de drift e destroy. O CI também aprovou a configuração. O ambiente foi removido ao final da validação.

Os [resultados e seus limites](docs/validation.md) estão registrados com os comandos e evidências da execução. Eles se referem às revisões indicadas nos relatórios.

## Quando terminar

```bash
bash scripts/tf.sh plan -destroy -out=.local/destroy.tfplan
bash scripts/tf.sh show .local/destroy.tfplan
bash scripts/tf.sh apply .local/destroy.tfplan
```

O destroy apaga o volume e todas as notas deste laboratório. As imagens ficam no cache Docker. O state e os planos ficam fora do Git; não apague o state enquanto ele ainda gerenciar recursos.

## Para ir além

O [guia de uso](docs/guide.md) reúne arquitetura, configuração, testes, limitações e ajuda para investigar problemas. O [portfólio](https://github.com/tommmdl/devops-portfolio) conecta este projeto aos outros laboratórios.

[Sobre a revisão do histórico](docs/history.md)

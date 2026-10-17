# Terraform: create, change and tear down an environment

English · [Português](README.md)

What if the network, database and containers were described in files you could review before running anything? This lab uses Terraform to build the notes app environment and follow its changes over time.

It runs on local Docker, without a cloud account or paid cloud resources. That leaves room to practise modules, state and drift before applying the ideas elsewhere.

[![Terraform](https://github.com/tommmdl/terraform-lab/actions/workflows/validate.yml/badge.svg)](https://github.com/tommmdl/terraform-lab/actions/workflows/validate.yml)

## Getting started

Linux/WSL, Docker, Bash, Python 3, curl and an available port 8002. Preparation can install Terraform 1.14.9 on Linux x86_64.

From the repository root:

```bash
bash scripts/prepare.sh
bash scripts/tf.sh init -input=false
bash scripts/tf.sh plan -out=.local/create.tfplan
bash scripts/tf.sh show .local/create.tfplan
bash scripts/tf.sh apply .local/create.tfplan
```

Review the plan before applying it. Once ready, the app is available at http://localhost:8002.

## Things to try

1. Review the six resources in the plan before creating the environment.
2. Run another plan after apply and look for pending changes.
3. Replace the containers and check that the notes remain in the database.
4. Stop the API outside Terraform and see how it detects and repairs drift.

## What has been tested

All 22 local checks passed, covering creation, no-op plans, persistence, drift repair and destroy. CI also validated the configuration. The test environment was removed after verification.

The [results and their limits](docs/validation.en.md) include execution details and evidence. They refer to the revisions recorded in those reports.

## When you are done

```bash
bash scripts/tf.sh plan -destroy -out=.local/destroy.tfplan
bash scripts/tf.sh show .local/destroy.tfplan
bash scripts/tf.sh apply .local/destroy.tfplan
```

Destroy deletes the volume and every note in this lab. Images remain in the Docker cache. State and plans stay out of Git; do not delete state while it still manages resources.

## A closer look

The [usage guide](docs/guide.en.md) covers architecture, configuration, tests, limitations and troubleshooting. The [portfolio](https://github.com/tommmdl/devops-portfolio) connects this project to the other labs.

[About the history update](docs/history.md)

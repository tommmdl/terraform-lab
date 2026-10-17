# Validation — 2026-10-17

[Português](validation.md)

**22 local checks passed**, completed at 19:08:59 America/Sao_Paulo (22:08:59 UTC). Actual Linux/WSL execution using Terraform 1.14.9, `kreuzwerker/docker` provider 4.6.0 and Docker Engine 29.1.3. Technical execution performed by the assistant with owner authorization.

## Observed lifecycle

| Stage | Result |
| --- | --- |
| fmt and validate | Passed |
| Invalid port (80) | Rejected before apply |
| Initial plan | 6 creates |
| Apply | Network, volume, images and containers provisioned |
| API | Readiness 200 and note creation 201 |
| Second plan | Exit 0, no changes |
| API and database replacement | Only 2 containers replaced; note preserved |
| Drift: API stopped outside Terraform | Plan exit 2; API replacement planned |
| Reconciliation | API ready again; note preserved |
| Post-reconciliation plan | Exit 0, no changes |
| Destroy plan | 6 deletes |
| Destroy | Empty state; containers, network and volume removed |
| Secret in state | Password contents absent from final state and backup |

The volume was deleted at test completion. No Terraform application remains running on port 8002. Images remain cached because `keep_locally = true`; empty local state, backups, binary and test files remain under ignored `.local/`. Other labs were not changed.

## Evidence

- [Checks and curated plan actions, without raw state](../evidence/lifecycle-results.json)
- [Runtime versions](../evidence/runtime.json)
- [Successful GitHub Actions validation](https://github.com/tommmdl/terraform-lab/actions/runs/39073809062)
- [CI steps and metadata](../evidence/ci-run.json)
- [Verification implementation](../scripts/verify.py)

CI ran fmt, init with backend disabled/read-only lockfile, and validate. It did not apply infrastructure. Raw plans, full local logs and state were not published because they can contain environment metadata. Evidence files were reviewed to exclude the local password.

## Limits

Persistence was tested by container replacement, not volume loss/restoration. Drift was tested by stopping the API, not every possible external modification. The provider chose to replace the stopped API to reconcile configuration. The password absence check covers this specific file, not a claim that all Terraform state is secret-free. No cloud, cloud costs, remote backend, backup/restore, load test or production deployment. The UI uses the artifact verified in earlier labs; application checks here used its API.

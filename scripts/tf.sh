#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
export TF_IN_AUTOMATION=1
if [ -x .local/bin/terraform ]; then
  exec .local/bin/terraform "$@"
fi
exec terraform "$@"

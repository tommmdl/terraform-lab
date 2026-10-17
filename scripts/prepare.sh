#!/usr/bin/env bash
set -euo pipefail
cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.."
python3 - <<'PY'
from pathlib import Path
import secrets
p = Path('.local')
p.mkdir(exist_ok=True)
p.chmod(0o700)
secret = p / 'db-password'
if not secret.exists():
    secret.write_text(secrets.token_urlsafe(32))
# Bind-mounted secret must be readable by the non-root API user.
secret.chmod(0o644)
PY
if [ ! -x .local/bin/terraform ] && ! command -v terraform >/dev/null 2>&1; then
  test "$(uname -s)" = Linux
  test "$(uname -m)" = x86_64
  mkdir -p .local/bin
  base=https://releases.hashicorp.com/terraform/1.14.9
  curl --fail --location "$base/terraform_1.14.9_linux_amd64.zip" -o .local/terraform.zip
  curl --fail --location "$base/terraform_1.14.9_SHA256SUMS" -o .local/SHA256SUMS
  python3 - <<'PY'
from pathlib import Path
import hashlib, zipfile
p = Path('.local')
expected = next(line.split()[0] for line in (p/'SHA256SUMS').read_text().splitlines()
                if line.split()[-1] == 'terraform_1.14.9_linux_amd64.zip')
if hashlib.sha256((p/'terraform.zip').read_bytes()).hexdigest() != expected:
    raise SystemExit('Terraform checksum mismatch')
with zipfile.ZipFile(p/'terraform.zip') as archive:
    (p/'bin/terraform').write_bytes(archive.read('terraform'))
(p/'bin/terraform').chmod(0o755)
print('Official Terraform archive SHA-256 verified')
PY
fi
bash scripts/tf.sh version

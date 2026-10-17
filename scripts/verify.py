#!/usr/bin/env python3
"""Exercise only this lab's dedicated Terraform state; destroy all its data."""
import json
from pathlib import Path
import subprocess
import time
import urllib.request
import uuid

ROOT = Path(__file__).resolve().parent.parent
LOCAL = ROOT / '.local'
TF = ['bash', 'scripts/tf.sh']
checks = []
plans = {}


def run(args, label, expected=(0,)):
    result = subprocess.run(args, cwd=ROOT, capture_output=True, text=True)
    (LOCAL / (label + '.log')).write_text(result.stdout + result.stderr)
    if result.returncode not in expected:
        raise RuntimeError(label + ' failed: ' + (result.stdout + result.stderr)[-3000:])
    return result


def check(name, value):
    if not value:
        raise AssertionError(name)
    checks.append(name)
    print('PASS: ' + name, flush=True)


def plan(label, *options, expected=(0,)):
    path = '.local/' + label + '.tfplan'
    result = run(TF + ['plan', '-input=false', '-no-color', '-out=' + path, *options], label, expected)
    data = json.loads(run(TF + ['show', '-json', path], label + '-json').stdout)
    changes = [{'address': item['address'], 'actions': item['change']['actions']}
               for item in data.get('resource_changes', []) if item['change']['actions'] != ['no-op']]
    plans[label] = changes
    return path, result.returncode, changes


def apply(path, label):
    run(TF + ['apply', '-input=false', '-no-color', path], label)


def call(path, method='GET', body=None):
    req = urllib.request.Request(url + path, method=method,
                                 data=None if body is None else json.dumps(body).encode(),
                                 headers={'Content-Type': 'application/json'})
    with urllib.request.urlopen(req, timeout=10) as response:
        raw = response.read()
        return response.status, json.loads(raw) if raw else None


LOCAL.mkdir(exist_ok=True)
if (LOCAL / 'terraform.tfstate').exists() and run(TF + ['state', 'list'], 'initial-state').stdout.strip():
    raise SystemExit('Expected empty dedicated state. Do not run against existing data.')
run(TF + ['fmt', '-check', '-recursive'], 'fmt')
check('Terraform formatting valid', True)
run(TF + ['validate', '-no-color'], 'validate')
check('Terraform configuration valid', True)
# Prove root variable validation rejects an invalid TCP port without creating resources.
invalid = run(TF + ['plan', '-input=false', '-no-color', '-var=api_port=80'], 'invalid-port', expected=(1,))
check('Invalid API port rejected before apply', 'api_port must be an integer' in invalid.stderr)
path, _, changes = plan('create')
check('Initial plan creates six managed resources', len(changes) == 6 and all(c['actions'] == ['create'] for c in changes))
apply(path, 'apply-create')
output = json.loads(run(TF + ['output', '-json'], 'outputs').stdout)
url = output['api_url']['value']
names = output['resource_names']['value']
check('All resource names isolated under terraform-lab prefix', all(v.startswith('terraform-lab-') for v in names.values()))
check('API ready after apply', call('/readyz')[0] == 200)
status, note = call('/notes', 'POST', {'title': 'terraform-' + uuid.uuid4().hex})
check('Create note returns 201', status == 201)
note_id = note['id']
_, code, changes = plan('no-op', '-detailed-exitcode', expected=(0,))
check('Second plan is idempotent: exit 0 and no changes', code == 0 and not changes)
path, _, changes = plan('replace-containers', '-replace=module.notes.docker_container.api', '-replace=module.notes.docker_container.db')
check('Replacement plan only replaces two containers', len(changes) == 2 and all(set(c['actions']) == {'delete', 'create'} for c in changes))
apply(path, 'apply-replacement')
check('Note survives API and database container replacement', any(n['id'] == note_id and n['title'] == note['title'] for n in call('/notes')[1]['notes']))
# A controlled out-of-band change demonstrates refresh, drift detection and reconciliation.
run(['docker', 'stop', names['api']], 'simulate-drift')
path, code, changes = plan('drift', '-detailed-exitcode', expected=(2,))
check('Stopped API produces drift: plan exit 2', code == 2 and any(c['address'] == 'module.notes.docker_container.api' for c in changes))
apply(path, 'apply-drift-repair')
check('API recovered after Terraform reconciliation', call('/readyz')[0] == 200)
check('Note survives drift repair', any(n['id'] == note_id for n in call('/notes')[1]['notes']))
_, code, changes = plan('final-no-op', '-detailed-exitcode', expected=(0,))
check('Reconciled infrastructure has no pending changes', code == 0 and not changes)
path, _, changes = plan('destroy', '-destroy')
check('Destroy plan removes six managed resources', len(changes) == 6 and all(c['actions'] == ['delete'] for c in changes))
apply(path, 'apply-destroy')
check('Terraform state empty after destroy', not run(TF + ['state', 'list'], 'final-state').stdout.strip())
for kind, name in [('container', names['api']), ('container', names['db']), ('network', names['network']), ('volume', names['volume'])]:
    result = subprocess.run(['docker', kind, 'inspect', name], capture_output=True, text=True)
    check(kind + ' removed: ' + name, result.returncode != 0 and ('no such' in result.stderr.lower() or 'not found' in result.stderr.lower()))
# State can contain sensitive metadata; export only curated resource actions and checks.
result = {'executed_at_utc': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
          'checks_passed': len(checks), 'checks': checks, 'plans': plans,
          'result': 'apply, idempotence, persistence, drift repair and destroy verified',
          'final_state_resource_count': 0, 'final_infrastructure': 'destroyed; cached images retained'}
secret = (LOCAL / 'db-password').read_text().strip()
for state in LOCAL.glob('terraform.tfstate*'):
    check('Password absent from ' + state.name, secret not in state.read_text())
result['checks_passed'] = len(checks)
result['checks'] = checks
(LOCAL / 'verification.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps(result, indent=2), flush=True)

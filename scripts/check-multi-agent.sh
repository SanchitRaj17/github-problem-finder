#!/usr/bin/env bash
set -euo pipefail
CONFIG="${CODEX_HOME:-$HOME/.codex}/config.toml"
if [[ ! -f "$CONFIG" ]]; then
  echo "Codex config not found: $CONFIG"
  echo "Create it and enable:"
  printf '[features]\nmulti_agent = true\n'
  exit 1
fi
python3 - "$CONFIG" <<'PY'
import re, sys
p=sys.argv[1]
s=open(p, encoding='utf-8').read()
m=re.search(r'(?ms)^\s*\[features\]\s*$([\s\S]*?)(?=^\s*\[|\Z)', s)
if m and re.search(r'(?m)^\s*multi_agent\s*=\s*true\s*(?:#.*)?$', m.group(1)):
    print(f"OK: multi_agent = true in {p}")
    raise SystemExit(0)
print(f"NOT ENABLED: multi_agent = true was not found under [features] in {p}")
raise SystemExit(1)
PY

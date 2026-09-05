#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

python3 -m venv "$ROOT/.venv-publication"
PY="$ROOT/.venv-publication/bin/python3"

"$PY" -m pip install --upgrade pip
"$PY" -m pip install -r "$ROOT/requirements-publication.txt"
"$PY" -m pip check

echo "PUBLICATION_VENV=$ROOT/.venv-publication"
echo "BOOTSTRAP_PUBLICATION_ENV=PASS"

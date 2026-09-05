#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PY="${PYTHON:-$ROOT/.venv-publication/bin/python3}"
PKGS="${COBAYA_PACKAGES_PATH:-$ROOT/external/cobaya_pkgs}"

[[ -x "$PY" ]] || { echo "Run scripts/bootstrap_publication_env.sh first."; exit 2; }
mkdir -p "$PKGS"

# CLASS itself is supplied by this repository, so only external likelihood/data
# requisites are installed here.
"$PY" -m cobaya.install \
  "$ROOT/configs/publication_mcmc.yaml" \
  --packages-path "$PKGS" \
  --skip "classy"

echo "COBAYA_PACKAGES_PATH=$PKGS"
echo "EXTERNAL_LIKELIHOOD_INSTALL=PASS"

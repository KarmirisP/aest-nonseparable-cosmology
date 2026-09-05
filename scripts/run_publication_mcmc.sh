#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PY="${PYTHON:-$ROOT/.venv-publication/bin/python3}"
PKGS="${COBAYA_PACKAGES_PATH:-$ROOT/external/cobaya_pkgs}"
N="${NCHAINS:-4}"

export COBAYA_PACKAGES_PATH="$PKGS"
export PYTHONNOUSERSITE=1
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export MALLOC_ARENA_MAX=2

cd "$ROOT"
exec mpirun -np "$N" "$PY" -m cobaya.run configs/publication_mcmc.yaml

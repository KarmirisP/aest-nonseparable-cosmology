#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PY="${PYTHON:-$ROOT/.venv-publication/bin/python3}"

export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1

[[ -x "$PY" ]] || { echo "Missing publication Python: $PY"; exit 2; }

cd "$ROOT/src/class"
rm -rf build python/build libclass.a
find python -maxdepth 1 -type f -name 'classy*.so' -delete 2>/dev/null || true
rm -f python/classy.cpp

make -j1 libclass.a

cd python
touch classy.pyx cclassy.pxd
"$PY" setup.py build

LIBDIR="$(find "$PWD/build" -maxdepth 1 -type d -name 'lib.*' | head -1)"
[[ -n "$LIBDIR" ]] || { echo "No python/build/lib.* directory"; exit 3; }

PYTHONPATH="$LIBDIR" "$PY" - <<'PY'
from classy import Class
Class()
print("CLASSY_IMPORT=PASS")
PY

echo "CLASS_BUILD=PASS"

#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PY="${PYTHON:-$ROOT/.venv-publication/bin/python3}"
PKGS="${COBAYA_PACKAGES_PATH:-$ROOT/external/cobaya_pkgs}"

export COBAYA_PACKAGES_PATH="$PKGS"
export PYTHONNOUSERSITE=1
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export MALLOC_ARENA_MAX=2

[[ -x "$PY" ]] || { echo "Publication venv missing."; exit 2; }
[[ -d "$PKGS" ]] || { echo "COBAYA_PACKAGES_PATH missing: $PKGS"; exit 3; }

"$PY" - <<'PY'
import sys, importlib.metadata as md
import numpy, pandas, astropy, mpi4py
assert sys.version_info[:2] == (3, 12)
assert numpy.__version__ == "1.26.4"
assert pandas.__version__ == "2.2.3"
assert astropy.__version__ == "7.1.0"
assert mpi4py.__version__ == "4.1.2"
assert md.version("cobaya") == "3.5.7"
print("PINNED_PYTHON_STACK=PASS")
PY

PYTHON="$PY" "$ROOT/scripts/build_class.sh"

LIBDIR="$(find "$ROOT/src/class/python/build" -maxdepth 1 -type d -name 'lib.*' | head -1)"
PYTHONPATH="$LIBDIR" "$PY" - <<'PY'
from classy import Class

p = {
    "gauge": "newtonian",
    "H0": 68.3206477851295,
    "omega_b": 0.02243860420421,
    "omega_cdm": 0.0,
    "omega_aest": 0.118813815536359,
    "Omega_Lambda": 0.0,
    "Omega_fld": 0.0,
    "Omega_vcdm_native": 0.6972944613049423,
    "vcdm_order": 4,
    "vcdm_s1": 4.3390577901,
    "vcdm_s2": -5.5743471279,
    "vcdm_s3": 1.891402037916349,
    "vcdm_s4": 0.34388729988365124,
    "aest_KB": 0.5,
    "aest_K2": 7500.0,
    "aest_Q0": 0.1,
    "aest_Z0": 1.0e-9,
    "aest_x0": 0.02672752,
    "aest_I0": 4.009128e-7,
    "n_s": 0.9675229700698749,
    "A_s": 2.090107487735015e-9,
    "tau_reio": 0.05408116436773863,
    "output": "tCl pCl lCl",
    "lensing": "yes",
    "l_max_scalars": 2508,
    "non_linear": "none",
}
c = Class()
c.set(p)
c.compute()
_ = c.lensed_cl(100)
c.struct_cleanup()
c.empty()
print("FROZEN_CLASS_POINT=PASS")
PY

cd "$ROOT"
"$PY" -m cobaya.run configs/publication_mcmc.yaml --test

echo "COBAYA_ALL_SIX_TEST=PASS"

mpirun -np 4 "$PY" -c '
from mpi4py import MPI
c=MPI.COMM_WORLD
print(f"MPI_RANK={c.rank} MPI_SIZE={c.size}", flush=True)
' > /tmp/aest_mpi_smoke.$$.log

[[ "$(grep -c 'MPI_SIZE=4' /tmp/aest_mpi_smoke.$$.log)" -eq 4 ]]
rm -f /tmp/aest_mpi_smoke.$$.log

echo "MPI_4_RANK_TEST=PASS"
echo "PUBLICATION_SMOKE_TEST=PASS"

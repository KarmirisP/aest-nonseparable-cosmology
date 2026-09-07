#!/usr/bin/env bash
set +e
set +u
set -o pipefail

ROOT="/home/unbinder/mcv2_theory_runs/zero_cdm_program"
RUN="$ROOT/AEST_NONSEPARABLE_PUBLICATION_MCMC_DAWN4_EXPLICIT_CLOSURE_R6"
LOG="$RUN/MCMC_DAWN4.log"
ENV="$ROOT/likelihood_env_numpy126"
PY="$ENV/bin/python3"

export PYTHONUNBUFFERED=1
export PYTHONNOUSERSITE=1
export OMP_NUM_THREADS=1
export OPENBLAS_NUM_THREADS=1
export MKL_NUM_THREADS=1
export NUMEXPR_NUM_THREADS=1
export MALLOC_ARENA_MAX=2
ulimit -c 0

echo "============================================================"
echo "AeST NONCYCLIC DAWN R6 — COMPACT LIVE MONITOR"
echo "============================================================"
echo "DATE=$(date -Is)"
echo "RUN=$RUN"

echo
echo "=== PROCESS ==="
pgrep -af "cobaya.run.*AEST_NONSEPARABLE_PUBLICATION_MCMC_DAWN4_EXPLICIT_CLOSURE_R6" || true

echo
echo "=== LATEST COBAYA MULTIVARIATE CONVERGENCE ==="
LATEST_CONV="$(grep -E "Convergence of means: R-1 =" "$LOG" 2>/dev/null | tail -1)"
LATEST_ACC="$(grep -E "Acceptance rate:" "$LOG" 2>/dev/null | tail -1)"
echo "${LATEST_ACC:-NO_ACCEPTANCE_LINE_YET}"
echo "${LATEST_CONV:-NO_CONVERGENCE_LINE_YET}"

RMIN="$(printf '%s\n' "$LATEST_CONV" | sed -nE 's/.*R-1 = ([0-9.eE+-]+).*/\1/p')"

if [[ -n "$RMIN" ]]; then
    "$PY" - "$RMIN" <<'PY'
import sys
r=float(sys.argv[1])
print(f"LATEST_RMINUS1={r:.9f}")
print("RMINUS1_TARGET=0.010000000")
print("CONVERGENCE_GATE=" + ("PASS" if r < 0.01 else "NOT_YET"))
PY
else
    echo "LATEST_RMINUS1=UNAVAILABLE"
    echo "CONVERGENCE_GATE=NOT_YET"
fi

echo
echo "=== CHAIN FILES ==="
ls -lh --time-style=long-iso "$RUN"/chains.[1-4].txt 2>/dev/null || true

echo
echo "=== CURRENT BEST SIX-LIKELIHOOD CHI2 ==="

"$PY" - "$RUN" <<'PY'
import sys, glob, os, math
import numpy as np

run=sys.argv[1]
files=sorted(glob.glob(os.path.join(run,"chains.[1-4].txt")))

if not files:
    print("CHAIN_DATA=NOT_YET")
    raise SystemExit(0)

required = [
    "chi2__planck_2018_highl_plik.TTTEEE_lite",
    "chi2__planck_2018_lowl.TT",
    "chi2__planck_2018_lowl.EE",
    "chi2__planck_2018_lensing.clik",
    "chi2__bao.desi_dr2.desi_bao_all",
    "chi2__sn.pantheonplus",
]

best=None
total_rows=0

for fn in files:
    with open(fn, "r", encoding="utf-8", errors="replace") as f:
        header=None
        rows=[]
        for line in f:
            if line.startswith("#"):
                if header is None:
                    header=line[1:].split()
                continue
            s=line.strip()
            if not s:
                continue
            parts=s.split()
            if header is None or len(parts) != len(header):
                continue
            try:
                vals=np.array([float(x) for x in parts], dtype=float)
            except ValueError:
                continue
            if not np.all(np.isfinite(vals)):
                continue
            rows.append(vals)

    if header is None or not rows:
        continue

    idx={name:i for i,name in enumerate(header)}
    missing=[x for x in required if x not in idx]
    if missing:
        print("STOP=MISSING_CHI2_COLUMNS", missing)
        raise SystemExit(20)

    arr=np.vstack(rows)
    total_rows += len(arr)

    chi = sum(arr[:,idx[x]] for x in required)
    j=int(np.argmin(chi))
    v=float(chi[j])

    if best is None or v < best[0]:
        best=(v, fn, j, idx, arr[j].copy())

print(f"TOTAL_COMPLETE_ROWS={total_rows}")

if best is None:
    print("CURRENT_MIN_CHI2=NOT_YET")
    raise SystemExit(0)

v, fn, j, idx, row = best

print(f"BEST_CHAIN={os.path.basename(fn)}")
print(f"BEST_ROW_ZERO_BASED={j}")
print(f"CURRENT_MIN_CHI2={v:.12f}")

labels=[
 ("Planck_highl",required[0]),
 ("Planck_lowTT",required[1]),
 ("Planck_lowEE",required[2]),
 ("Planck_lensing",required[3]),
 ("DESI_DR2",required[4]),
 ("PantheonPlus",required[5]),
]
for lab,col in labels:
    print(f"{lab}={row[idx[col]]:.12f}")

for p in ["H0","omega_b","omega_aest","vcdm_s4","vcdm_s3","n_s","ln10As","A_s","tau_reio","Omega_vcdm_native","A_planck"]:
    if p in idx:
        print(f"{p}={row[idx[p]]:.12g}")

frozen=2422.696204
lcdm=2428.9192
N=2392
dchi=v-lcdm
daic=dchi + 2
dbic=dchi + math.log(N)

print(f"FROZEN_OPTIMIZED_CHI2={frozen:.12f}")
print(f"DELTA_CURRENT_MINUS_FROZEN={v-frozen:+.12f}")
print(f"LCDM_REFERENCE_CHI2={lcdm:.12f}")
print(f"DELTA_CHI2_VS_LCDM={dchi:+.12f}")
print(f"DELTA_AIC_VS_LCDM={daic:+.12f}")
print(f"DELTA_BIC_VS_LCDM={dbic:+.12f}")
PY

MON_RC=$?

echo
echo "=== VERDICT ==="
if [[ "$MON_RC" -eq 0 ]]; then
    echo "READ_ONLY_MONITOR=PASS"
else
    echo "READ_ONLY_MONITOR=ERROR_RC_$MON_RC"
fi
echo "NOTE=BEST_CHI2_IS_PROVISIONAL_UNTIL_RMINUS1_LT_0P01"
echo "FINAL_RC=$MON_RC"

exit "$MON_RC"

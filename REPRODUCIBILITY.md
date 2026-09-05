# Publication reproducibility

This repository contains the frozen modified CLASS/hi_class source and the
portable Cobaya input used for the noncyclic AeST + Type-II/VCDM publication
posterior.

## Verified DAWN contract

The publication stack was verified on DAWN with four MPI ranks before this
environment was frozen.

Core versions:

- Python 3.12.3
- NumPy 1.26.4
- pandas 2.2.3
- Astropy 7.1.0
- Cobaya 3.5.7
- Cython 3.3.0
- mpi4py 4.1.2
- GetDist 1.7.7
- modified CLASS/hi_class v3.2.3-family source in `src/class`
- Planck clik runtime observed: `clik_16.0b1-12-gcde855c6debd`

The full pip freeze is `requirements-publication.txt`.

## Non-obvious compatibility locks

The following are deliberate publication choices, not optional setup hints:

- Cobaya `classy.path` points to the CLASS **root**: `./src/class`.
- `ignore_obsolete: true` is required because this is a validated modified
  pre-3.3 CLASS branch.
- Build the Python wrapper with `python setup.py build`, not only
  `build_ext --inplace`; Cobaya expects `python/build/lib.*`.
- `src/class/python/cclassy.pxd` is required. Its SHA-256 is
  `4e2d593f8a853690764f86406f0c3154500a3b281d5de7157e60b1067605dca6`.
- `classy.cpp` is generated and is intentionally not versioned.
- Baseline `non_linear` is explicitly `none`.
- Baseline `P_k_max_h/Mpc` is intentionally absent because the six-likelihood
  configuration requests CMB/lensing/distances, not `mPk`.
- The source prior is flat in `ln(10^10 A_s)`, not in `A_s`.

## Baseline likelihoods

The canonical `configs/publication_mcmc.yaml` uses:

- `planck_2018_highl_plik.TTTEEE_lite`
- `planck_2018_lowl.TT`
- `planck_2018_lowl.EE`
- `planck_2018_lensing.clik`
- `bao.desi_dr2.desi_bao_all`
- `sn.pantheonplus`

SH0ES is not part of the baseline posterior.

External Planck/DESI/Pantheon+ code/data are not redistributed here. Set
`COBAYA_PACKAGES_PATH` to a Cobaya packages directory or install them with
`scripts/install_likelihoods.sh`.

## Scientific parameter mapping

Seven source coordinates are sampled:

`H0, omega_b, omega_aest, vcdm_s4, n_s, ln10As, tau_reio`.

Dependent CLASS inputs are evaluated at every trial point:

```text
Omega_vcdm_native =
  1 - (omega_b + omega_aest + 4.1774922280010673e-05)/(H0/100)^2

vcdm_s3 =
  2.2352893378 - vcdm_s4

A_s =
  1e-10 * exp(ln10As)
```

The baseline fixes:

```text
omega_cdm   = 0
Omega_Lambda = 0
Omega_fld    = 0
non_linear   = none
```

The MCMC convergence target is `Rminus1_stop: 0.01`.

## Native reproduction

System prerequisites on Ubuntu-like hosts:

```bash
sudo apt-get install \
  python3 python3-venv python3-dev \
  build-essential gfortran pkg-config cmake swig \
  openmpi-bin libopenmpi-dev \
  libgsl-dev libfftw3-dev libcfitsio-dev \
  liblapack-dev libblas-dev libhdf5-dev
```

Then:

```bash
./scripts/bootstrap_publication_env.sh
export COBAYA_PACKAGES_PATH=/path/to/cobaya_pkgs
./scripts/install_likelihoods.sh
./scripts/smoke_test.sh
./scripts/run_publication_mcmc.sh
```

## Docker

Build the software image:

```bash
docker build -t aest-publication -f environment/Dockerfile .
```

Run the smoke test while mounting externally installed likelihoods:

```bash
docker run --rm -it \
  -v /path/to/cobaya_pkgs:/opt/cobaya_pkgs:ro \
  aest-publication \
  ./scripts/smoke_test.sh
```

## Apptainer/Singularity

Build:

```bash
apptainer build aest-publication.sif environment/apptainer.def
```

For the full repository workflow, bind the repository and likelihood directory,
then run the same smoke-test/run scripts.

## Required smoke-test endpoint

A reproduction should not be treated as valid unless it reaches:

```text
PINNED_PYTHON_STACK=PASS
CLASS_BUILD=PASS
CLASSY_IMPORT=PASS
FROZEN_CLASS_POINT=PASS
COBAYA_ALL_SIX_TEST=PASS
MPI_4_RANK_TEST=PASS
PUBLICATION_SMOKE_TEST=PASS
```

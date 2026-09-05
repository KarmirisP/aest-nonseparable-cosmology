# Reproducibility environments

Two supported paths are supplied:

1. Native Python/MPI environment using the exact freeze in
   `../requirements-publication.txt`.
2. Containerized software environment using `Dockerfile` or `apptainer.def`.

The large external Planck/DESI/Pantheon+ likelihood packages and datasets are
not embedded in the repository or image. They are installed/mounted separately
through `COBAYA_PACKAGES_PATH`.

The host and package versions actually verified on DAWN are recorded in
`versions_DAWN.txt` and `host_DAWN.txt`.

See `../REPRODUCIBILITY.md` for the complete procedure and non-obvious CLASS /
Cobaya compatibility locks.

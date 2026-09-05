FROM ubuntu:24.04

ENV DEBIAN_FRONTEND=noninteractive \
    PYTHONUNBUFFERED=1 \
    PYTHONNOUSERSITE=1 \
    OMP_NUM_THREADS=1 \
    OPENBLAS_NUM_THREADS=1 \
    MKL_NUM_THREADS=1 \
    NUMEXPR_NUM_THREADS=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-venv python3-dev python3-pip \
    build-essential gfortran git ca-certificates curl wget \
    pkg-config cmake swig \
    openmpi-bin libopenmpi-dev \
    libgsl-dev libfftw3-dev libcfitsio-dev \
    liblapack-dev libblas-dev libhdf5-dev \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /work
COPY . /work

RUN python3 -m venv /opt/aest-venv \
 && /opt/aest-venv/bin/python -m pip install --upgrade pip \
 && /opt/aest-venv/bin/python -m pip install -r /work/requirements-publication.txt \
 && PYTHON=/opt/aest-venv/bin/python /work/scripts/build_class.sh

ENV PATH="/opt/aest-venv/bin:${PATH}" \
    COBAYA_PACKAGES_PATH="/opt/cobaya_pkgs"

CMD ["/bin/bash"]

#!/usr/bin/env python3
import hashlib, json
from pathlib import Path
ROOT=Path(__file__).resolve().parents[1]
d=json.loads((ROOT/'evidence/PUBLICATION_SUMMARY.json').read_text())
assert d['chi2_theory'] == 2422.695966726233
assert d['final_parameters']['omega_cdm'] == 0.0
assert d['final_parameters']['Omega_Lambda'] == 0.0
assert d['particle_cdm_profile']['zero_cdm_delta_chi2'] < 1.0
assert d['fast_scalar_cutoff_eV'] > 0.0
p=ROOT/'src/class/source/perturbations.c'
if p.exists():
    sha=hashlib.sha256(p.read_bytes()).hexdigest()
    assert sha == d['source_sha256'], (sha,d['source_sha256'])
print('PUBLICATION_MANIFEST_TEST=PASS')

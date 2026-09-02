# Nonseparable AeST + Type-II cosmology

Reproducibility repository for the manuscript:

**A Stable Single-Metric Relativistic Modified-Gravity Cosmology without Particle Cold Dark Matter or a Bare Cosmological Constant**

Author: Panagiotis Karmiris (Independent Researcher, Greece)

## Scientific scope

This repository contains the publication-facing implementation and evidence for a single-metric relativistic modified-gravity cosmology combining:

- an aether scalar--tensor (AeST) metric/vector/scalar sector;
- a current-fixed nonseparable scalar kinetic operator;
- a nondynamical Type-II/VCDM acceleration constraint sector;
- zero particle cold dark matter in the primary realization;
- zero bare cosmological constant;
- a CLASS implementation and matched control/regression tests;
- Planck 2018 + DESI DR2 + Pantheon+ likelihood analysis;
- an independent particle-CDM profile;
- the tested static SPARC no-halo limit.

## Reproduce the paper

```bash
python3 scripts/generate_publication_figures.py \
  --summary evidence/PUBLICATION_SUMMARY.json \
  --out paper/figures

cd paper
latexmk -pdf -interaction=nonstopmode aest_nonseparable_cosmology.tex
```

## Source integrity

The exact frozen modified CLASS source must be copied byte-for-byte from the certified research source. The SHA-256 of `source/perturbations.c` must be:

```
1b76e97333efd654736519bf324976dba0906192f674f6d05e74f883f416c479
```

Historical development labels may remain inside comments of the frozen C source. They are provenance comments only and are deliberately not edited after the source freeze, because byte-level reproducibility takes precedence over cosmetic renaming inside certified source files.

## Repository policy

The GitHub repository contains the exact publication source, compact machine-readable evidence, tests, manuscript, and figure code. Large frozen research archives can be deposited with the DOI-bearing archival release rather than committed to GitHub.

## Citation and archival DOI

The exact submission tag should be archived in Zenodo (or an equivalent DOI-bearing service). Add the DOI to `CITATION.cff` and the manuscript Data Availability Statement before submission.

## Final configuration and compact regression

The final publication parameter file is `configs/final_cosmology.ini`.
After assembling the exact CLASS tree, run:

```bash
python3 tests/test_publication_manifest.py
```

This verifies the frozen statistical locks and, when `src/class/` is present,
the certified perturbation-source SHA-256.

#!/usr/bin/env bash
set -Eeuo pipefail
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"
python3 scripts/generate_publication_figures.py --summary evidence/PUBLICATION_SUMMARY.json --out paper/figures
(cd paper && latexmk -pdf -interaction=nonstopmode aest_nonseparable_cosmology.tex)
find evidence paper scripts config -type f -print0 | sort -z | xargs -0 sha256sum > evidence/RELEASE_SHA256SUMS

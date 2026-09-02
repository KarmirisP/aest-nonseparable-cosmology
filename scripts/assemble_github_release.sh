#!/usr/bin/env bash
set -Eeuo pipefail

if [ "$#" -lt 2 ]; then
  echo "Usage: $0 /path/to/certified/class/tree /path/to/public/repository"
  exit 2
fi
SOURCE_TREE="$1"
DEST="$2"
EXPECTED="1b76e97333efd654736519bf324976dba0906192f674f6d05e74f883f416c479"
PKG="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

ACTUAL="$(sha256sum "$SOURCE_TREE/source/perturbations.c" | awk '{print $1}')"
echo "EXPECTED_SOURCE_SHA=$EXPECTED"
echo "ACTUAL_SOURCE_SHA=$ACTUAL"
[[ "$ACTUAL" == "$EXPECTED" ]] || { echo "ERROR=CERTIFIED_SOURCE_HASH_MISMATCH"; exit 20; }

mkdir -p "$DEST"
rsync -a --delete --exclude='.git/' --exclude='paper/*.aux' --exclude='paper/*.log' \
  --exclude='paper/*.out' --exclude='paper/*.fls' --exclude='paper/*.fdb_latexmk' \
  "$PKG/" "$DEST/"

mkdir -p "$DEST/src/class" "$DEST/configs"
rsync -a --delete --exclude='.git/' --exclude='build/' --exclude='python/build/' \
  --exclude='output/' --exclude='__pycache__/' --exclude='*.pyc' \
  "$SOURCE_TREE/" "$DEST/src/class/"

# Final parameter file is publication-facing and should be supplied/copyable
# from the certified local result when available. This package also contains
# the final numerical parameters in evidence/PUBLICATION_SUMMARY.json.
find "$SOURCE_TREE" -maxdepth 2 -type f \( -iname 'license*' -o -iname 'copying*' -o -iname 'readme*' \) \
  -print > "$DEST/evidence/UPSTREAM_LICENSE_FILES.txt" || true

cd "$DEST"
python3 scripts/generate_publication_figures.py --summary evidence/PUBLICATION_SUMMARY.json --out paper/figures

if command -v latexmk >/dev/null 2>&1; then
  (cd paper && latexmk -pdf -interaction=nonstopmode aest_nonseparable_cosmology.tex)
fi

find paper scripts evidence src -type f -print0 | sort -z | xargs -0 sha256sum > evidence/RELEASE_SHA256SUMS
echo "PUBLIC_REPOSITORY_TREE=$DEST"
echo "CERTIFIED_SOURCE_HASH_LOCK=PASS"
echo "ASSEMBLY=PASS"

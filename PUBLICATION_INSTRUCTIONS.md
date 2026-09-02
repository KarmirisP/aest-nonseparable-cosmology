# Publication and GitHub instructions

## 1. Extract the downloaded package from Windows Downloads in WSL

For your current Windows account, the usual path is:

```bash
mkdir -p ~/projects
cd ~/projects

tar -xzf /mnt/c/Users/unbin/Downloads/aest_nonseparable_prd_final.tar.gz
cd aest_nonseparable_prd_final
```

If the filename differs, list Downloads first:

```bash
ls -lh /mnt/c/Users/unbin/Downloads
```

## 2. Install LaTeX in WSL (MiKTeX is not required)

```bash
sudo apt update
sudo apt install -y \
  texlive-latex-base texlive-latex-extra texlive-publishers \
  texlive-science texlive-bibtex-extra texlive-binaries latexmk
```

Compile:

```bash
python3 scripts/generate_publication_figures.py \
  --summary evidence/PUBLICATION_SUMMARY.json \
  --out paper/figures

cd paper
latexmk -pdf -interaction=nonstopmode aest_nonseparable_cosmology.tex
cd ..
```

## 3. Assemble the public repository with the exact certified CLASS tree

Do not manually edit the frozen CLASS source. Run:

```bash
./scripts/assemble_github_release.sh \
  <path-to-certified-class-tree> \
  ~/projects/aest-nonseparable-cosmology
```

The script checks the certified perturbation-source hash before copying.

## 4. Create the GitHub repository

```bash
cd ~/projects/aest-nonseparable-cosmology

git init
git branch -M main
git add .
git commit -m 'Initial reproducibility release for PRD submission'

sudo apt install -y gh
gh auth login

gh repo create KarmirisP/aest-nonseparable-cosmology \
  --public --source=. --remote=origin --push

git tag -a v1.0.0-submission -m 'PRD submission reproducibility release'
git push origin v1.0.0-submission
```

## 5. Archive exact release with a DOI

Connect the GitHub repository to Zenodo, create a GitHub release for `v1.0.0-submission`, and record the minted DOI. Update:

- `CITATION.cff`
- manuscript Data Availability Statement
- reproducibility appendix

Then make one final commit/tag if the DOI insertion changes source files.

## 6. APS/PRD submission

Submit as a Physical Review D Research Article. Before submission:

- authenticate your ORCID in the APS account;
- replace the repository/DOI placeholders;
- compile from a clean Git checkout;
- check the generated APS PDF against the local PDF;
- for the initial APS submission, upload the single compiled manuscript PDF; keep the TeX, BibTeX, and figure source ready for editorial/production requests and acceptance;
- include the AI-assistance disclosure already present in the manuscript;
- upload the cover letter;
- verify author name: Panagiotis Karmiris;
- affiliation: Independent Researcher, Greece;
- contact email: unbinder@msn.com.

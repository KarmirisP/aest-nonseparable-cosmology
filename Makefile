figures:
	python3 scripts/generate_publication_figures.py --summary evidence/PUBLICATION_SUMMARY.json --out paper/figures

paper: figures
	cd paper && latexmk -pdf -interaction=nonstopmode aest_nonseparable_cosmology.tex

clean:
	cd paper && latexmk -C || true

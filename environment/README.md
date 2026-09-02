# Environment

The manuscript/figure layer requires Python 3 with NumPy and Matplotlib plus a
LaTeX distribution containing REVTeX 4.2, BibTeX and latexmk.

The full cosmological likelihood reproduction additionally requires the exact
CLASS source in `src/class/`, Cobaya and the external Planck/DESI/Pantheon+
likelihood packages described in Appendix G of the manuscript. Those external
data/likelihood packages are not redistributed here when their own licenses or
installers should be used instead.

The frozen likelihood analysis used NumPy 1.26.4. Record complete package
versions in the DOI-bearing release manifest when assembling from the research
machine.

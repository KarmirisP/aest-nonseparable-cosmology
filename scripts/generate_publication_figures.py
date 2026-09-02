#!/usr/bin/env python3
import json, argparse
from pathlib import Path
import numpy as np
import matplotlib.pyplot as plt

ap=argparse.ArgumentParser()
ap.add_argument('--summary', default='evidence/PUBLICATION_SUMMARY.json')
ap.add_argument('--out', default='paper/figures')
a=ap.parse_args(); d=json.load(open(a.summary)); out=Path(a.out); out.mkdir(parents=True,exist_ok=True)

def save(fig,name):
    fig.tight_layout(); fig.savefig(out/(name+'.pdf'),bbox_inches='tight'); fig.savefig(out/(name+'.png'),dpi=220,bbox_inches='tight'); plt.close(fig)

fig,ax=plt.subplots(figsize=(5.5,3.8)); vals=[d['chi2_theory'],d['chi2_lcdm']]; labs=['Modified gravity',r'$\Lambda$CDM']; ax.bar(labs,vals); ax.set_ylabel(r'$\chi^2$'); ax.set_ylim(min(vals)-2,max(vals)+2); ax.set_title('Matched six-likelihood fit')
for i,v in enumerate(vals): ax.text(i,v+0.12,f'{v:.3f}',ha='center',fontsize=9)
save(fig,'fig_chi2_comparison')

x=np.array([0,0.00025,0.0005,0.001,0.002,0.005,0.01,0.02,0.04]); y=np.array([0.9581185850,0.7226,0.1814,0.0,0.0939,0.1268,0.0726,0.0575,0.0300])
fig,ax=plt.subplots(figsize=(5.5,3.8)); ax.plot(x,y,marker='o'); ax.axhline(1,linestyle='--'); ax.set_xlabel(r'$\omega_{\rm cdm}$'); ax.set_ylabel(r'$\Delta\chi^2_{\rm profile}$'); ax.set_title('Independent particle-CDM profile'); save(fig,'fig_cdm_profile')

b=d['operator_ablation']; labs=['internal','E',r'$\chi$',r'$\delta$',r'$\theta$','CMB',r'$P(k)$']; vals=[b['internal'],b['E'],b['chi'],b['delta'],b['theta'],b['cmb_max_rel'],b['pk_max_rel']]
fig,ax=plt.subplots(figsize=(6.3,3.9)); ax.bar(labs,vals); ax.set_yscale('log'); ax.set_ylabel('maximum normalized / relative response'); ax.set_title('Matched nonseparable-operator ablation'); save(fig,'fig_operator_ablation')

c=d['likelihood_components']; fig,ax=plt.subplots(figsize=(6.5,4.0)); labs=list(c); vals=list(c.values()); ax.barh(labs,vals); ax.set_xlabel(r'$\chi^2$ contribution'); ax.set_title('Likelihood decomposition'); save(fig,'fig_likelihood_components')

KB=.5; Q0=.1; Z0=1e-9; x0=.02672752; I0=4.009128e-7
aa=np.geomspace(1e-12,1,1000); xx=x0/aa**3; Q=Q0+Z0*np.arcsinh(xx); A=2*I0*KB/(Q*aa**3)-4*KB+8; CoverH=2*I0*(2-KB)/aa**3
fig,ax=plt.subplots(figsize=(5.8,4.0)); ax.loglog(aa,A,label=r'$A$'); ax.loglog(aa,CoverH,label=r'$C/H$'); ax.set_xlabel('scale factor $a$'); ax.set_ylabel('positive coefficient'); ax.set_title('Radiation-sector Hurwitz coefficients'); ax.legend(); save(fig,'fig_radiation_stability')

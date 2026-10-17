# qPCR open tools: local test bench

Free qPCR analysis tools, collected so you can run and compare them locally (17 Oct 2026).
None of the analysis code here is ours. Each upstream repo is a git submodule under `src/`
and keeps its own licence. Only the scripts and this README are this repo's (MIT).

## Quick start

Needs git, Python 3.11, and Node + npm.

```bash
git clone https://github.com/ShivaTeja05/Qpcr-.git qpcr-open-tools
cd qpcr-open-tools
scripts/setup.sh          # fetches submodules, makes venvs, builds the RDML-Tools UI
scripts/run-rdml-tools.sh # http://localhost:1234/index.html
scripts/run-autoqpcr.sh   # http://localhost:5055
```

## What runs (tested on the tools' own example data)

| Tool | Input | What it does | Licence | Status | How to run |
|---|---|---|---|---|---|
| **LinRegPCR** in [rdmlpython](https://github.com/RDML-consortium/rdmlpython) | Raw amplification curves (RDML) | Baseline, per-well PCR efficiency, Cq/TD0, N0, melt curves | MIT | ✅ CLI works, 16 wells, mean eff 1.745 | see below |
| **RDML-Tools** web app ([rdml-tools](https://github.com/RDML-consortium/rdml-tools)) | RDML | Web UI for LinRegPCR, melt, plate correction, geNorm, relative/absolute quant, validate/edit | GPL-3 | ✅ Runs locally, LinRegPCR matches CLI | `scripts/run-rdml-tools.sh` → http://localhost:1234/index.html |
| **bioeng-qpcr** ([repo](https://github.com/tomaxiwu-bit/bioeng-qpcr)) | Cq CSV, RDML, raw curves | MIQE readiness PASS/WARN/FAIL, ΔΔCq/Pfaffl/efficiency-corrected, geNorm/NormFinder/BestKeeper, outliers, provenance, HTML report, **MCP server** | MIT | ✅ validate + curves work | `.venv/bin/bioeng-qpcr --help` |
| **qpcr** ([repo](https://github.com/NoahHenrikKleinschmidt/qpcr)) | Ct CSV/Excel | ΔΔCt pipelines, multiple normalisers, stats, plots | GPL-3 | ✅ example pipeline works | `.venv/bin/python -I scripts/test_qpcr_pkg.py "<data dir>" <out dir>` |
| **Auto-qPCR** ([repo](https://github.com/neuroeddu/Auto-qPCR)) | Instrument CSV export (Ct) | Absolute, ΔCt, ΔΔCt, stability, outliers, stats, plots → ZIP | GPL-3 | ✅ web app works (needs pandas 1.5) | `scripts/run-autoqpcr.sh` → http://localhost:5055 |

Commands below write to `test-output/`, which git ignores.

### Commands

```bash
cd qpcr-open-tools
S=src/RDML-consortium_rdml-tools/server
# LinRegPCR on raw curves
mkdir -p test-output
.venv/bin/python -I $S/rdmlpython/rdml.py -lrp $S/linregpcr.rdml \
  --pcrEfficiencyExl 0.05 --excludeNoPlateau --excludeEfficiency mean \
  -o test-output/linreg_out.rdml --saveResults test-output/linregpcr_results.tsv
# MIQE readiness + raw-curve fitting
.venv/bin/bioeng-qpcr validate src/tomaxiwu-bit_bioeng-qpcr/examples/qpcr_simple_plate_example.csv
.venv/bin/bioeng-qpcr curves   src/tomaxiwu-bit_bioeng-qpcr/examples/amplification_curves_example.csv
```

Example RDML files to try: `src/RDML-consortium_rdml-tools/server/*.rdml`
(linregpcr, meltingcurveanalysis, genorm, relative, absolute, two/six-plate correction).

### What `setup.sh` and the run scripts change compared with upstream instructions
- rdmlpython: use the copy in `rdml-tools/server/rdmlpython`. The standalone clone lacks its `schema/` submodule.
- RDML-Tools client: built with Parcel 2.16 (old `lmdb` will not build on Node 24), using a generated `client/.env.production` that points at localhost.
- RDML-Tools server: started with `flask run --host 127.0.0.1`. Upstream `server.py` binds `0.0.0.0` with `debug=True`, which exposes the Werkzeug debugger to the network.
- Auto-qPCR: separate `.venv-autoqpcr` with pandas 1.5.3, because it uses `DataFrame.append`, which pandas 2 removed. Port 5055, because macOS AirPlay uses 5000. Note: its repo commits Mailtrap SMTP credentials in `application/__init__.py`.

## Cloned but not run
- **pcr** (R, GPL-3) and **RDML** (R, MIT): need R. R is not installed (`brew install r`).
- **eleven** (Python geNorm): Python 2.7 only.
- Also R-only and not cloned: `qpcR` (Ritz/Spiess, sigmoid model fitting), `chipPCR`, `MBmca`, Bioconductor `HTqPCR` / `NormqPCR` / `ReadqPCR`.

## Free to use online, no setup
- RDML-Tools / web LinRegPCR, the hosted version of the app above: https://www.gear-genomics.com/rdml-tools/
- Auto-qPCR: https://auto-q-pcr.com/
- Qupid (Streamlit UI for `qpcr`), linked from the qpcr README.
- LinRegPCR desktop: a free Windows-only `.exe`. Superseded by the web version.

## Vendor software (not free and open)
- **Thermo Fisher Design & Analysis 2 / QuantStudio**: download via Thermo Fisher Connect after sign-in, and the pages tie it to owning an instrument. Not checked whether it is free without one.
- **Bio-Rad CFX Maestro 2.3**: a paid product with an order number. There is a Mac edition, but it doesn't control the instrument.
- These need accounts, so they weren't set up here.

## Relevance to qPilot
- qPilot can `import` **rdmlpython** (MIT) as a reference LinRegPCR implementation to cross-check our Cq and efficiency.
- **bioeng-qpcr** (MIT, alpha, created 6 Sep 2026, 1 star, single push) overlaps closely: auditable engine, MIQE readiness states, provenance, MCP server. Treat it as a competitor and compare before pitching. Its sigmoid-fit "Eff" (~0.55) is defined differently from LinRegPCR's (~1.75 = 75%).
- The GPL-3 tools (rdml-tools, qpcr, Auto-qPCR) can be run alongside as outside tools. Don't copy their code into an MIT/Apache repo.

#!/bin/bash
# One-shot setup for the qPCR open-tools bench (macOS/Linux).
# Needs: git, python3.11, node + npm. Safe to re-run.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
PY="${PYTHON:-python3.11}"

echo "==> Fetching upstream tools (git submodules)"
git submodule update --init --recursive --depth 1

echo "==> Main venv (.venv): rdmlpython deps, qpcr, bioeng-qpcr"
[ -d .venv ] || "$PY" -m venv .venv
.venv/bin/pip -q install --upgrade pip
.venv/bin/pip -q install lxml numpy scipy matplotlib flask flask-cors qpcr
.venv/bin/pip -q install "./src/tomaxiwu-bit_bioeng-qpcr[plot]"

echo "==> Auto-qPCR venv (.venv-autoqpcr): needs pandas 1.x (uses DataFrame.append)"
[ -d .venv-autoqpcr ] || "$PY" -m venv .venv-autoqpcr
.venv-autoqpcr/bin/pip -q install --upgrade pip
.venv-autoqpcr/bin/pip -q install flask flask-mail matplotlib scipy \
  "pandas==1.5.3" "numpy<2" "pingouin==0.5.3" "setuptools<70"

echo "==> RDML-Tools web client"
CLIENT=src/RDML-consortium_rdml-tools/client
# Upstream's Parcel 2.5 pulls an lmdb that won't build on Node 24; 2.16 ships prebuilt binaries.
printf 'API_URL=http://localhost:3300/api/v1\nAPI_LINK=http://localhost:1234/\nINDEX_LINK_URL=http://localhost:1234/index.html\n' \
  > "$CLIENT/.env.production"
(cd "$CLIENT" && npm install --no-audit --no-fund --no-save parcel@2.16.0 \
  && rm -rf dist && npx parcel build src/*.html --no-cache --no-source-maps --public-url ./)

echo
echo "Done. Try:"
echo "  scripts/run-rdml-tools.sh   # http://localhost:1234/index.html (LinRegPCR etc.)"
echo "  scripts/run-autoqpcr.sh     # http://localhost:5055"
echo "  .venv/bin/bioeng-qpcr --help"

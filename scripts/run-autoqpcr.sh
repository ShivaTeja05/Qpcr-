#!/bin/bash
# Runs the Auto-qPCR web app locally: http://localhost:5055
# (port 5000 is taken by AirPlay on macOS)
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/src/neuroeddu_Auto-qPCR/website/Auto-q-pcr-frontend"
exec "$ROOT/.venv-autoqpcr/bin/flask" --app main.py run --host 127.0.0.1 --port 5055

#!/bin/bash
# Runs RDML-Tools (incl. web LinRegPCR) locally, bound to 127.0.0.1 only.
# API: http://localhost:3300   UI: http://localhost:1234/index.html
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
T="$ROOT/src/RDML-consortium_rdml-tools"
mkdir -p "$T/data" "$T/log"
cd "$T/server"
# flask run instead of server.py: upstream's __main__ binds 0.0.0.0 with debug=True
"$ROOT/.venv/bin/flask" --app server.py run --host 127.0.0.1 --port 3300 &
API=$!
"$ROOT/.venv/bin/python" -m http.server 1234 --bind 127.0.0.1 --directory "$T/client/dist" &
UI=$!
trap 'kill $API $UI' EXIT
echo "RDML-Tools UI: http://localhost:1234/index.html"
wait

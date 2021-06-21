#!/bin/bash

set -euo pipefail

script_dir="$( cd "$( /usr/bin/dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
curl -s https://raw.githubusercontent.com/cheretbe/bootstrap/master/setup_venv.py?flush_cache=True \
  | /usr/bin/python3 - backuppc-scripts --requirement ${script_dir}/requirements.txt --batch-mode

"${HOME}/.cache/venv/backuppc-scripts/bin/python3" \
  ${script_dir}/snapshots.py "$@"

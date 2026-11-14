#!/usr/bin/env bash
# Replace the placeholder Git repo URL in every Argo CD manifest.
set -euo pipefail
NEW="${1:?usage: set-repo-url.sh https://github.com/you/sample-platform.git}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
grep -rl "repoURL: https://github.com/YOUR_USER/sample-platform.git" "$ROOT/gitops" "$ROOT/templates" \
  | while read -r f; do
      sed -i.bak "s#https://github.com/YOUR_USER/sample-platform.git#${NEW}#g" "$f" && rm -f "$f.bak"
      echo "updated $f"
    done

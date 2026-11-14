#!/usr/bin/env bash
# The "golden path": scaffold a production-ready service from the template.
# Usage: ./scripts/new-service.sh payments [team-name]
set -euo pipefail

NAME="${1:?usage: new-service.sh <service-name> [team]}"
TEAM="${2:-platform-demo}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
DEST="$ROOT/services/$NAME"

[[ "$NAME" =~ ^[a-z][a-z0-9-]{1,30}$ ]] || { echo "name must be lowercase dns-safe (e.g. payments-api)"; exit 1; }
[[ -e "$DEST" ]] && { echo "service '$NAME' already exists at $DEST"; exit 1; }

echo "==> Creating services/$NAME from golden-path template"
mkdir -p "$ROOT/services"
cp -R "$ROOT/templates/python-service" "$DEST"

# Replace placeholders in every file
grep -rl "__SERVICE_NAME__\|__TEAM__" "$DEST" | while read -r f; do
  sed -i.bak -e "s/__SERVICE_NAME__/$NAME/g" -e "s/__TEAM__/$TEAM/g" "$f" && rm -f "$f.bak"
done

mkdir -p "$ROOT/.github/workflows"
mv "$DEST/.github/workflows/ci.yaml" "$ROOT/.github/workflows/$NAME-ci.yaml" && rm -rf "$DEST/.github"

echo "==> Registering services/$NAME with Argo CD"
sed -e "s/__SERVICE_NAME__/$NAME/g" -e "s/__TEAM__/$TEAM/g" \
  "$ROOT/gitops/apps/_app-template.yaml.tpl" > "$ROOT/gitops/apps/$NAME.yaml"

cat <<EOF

Service '$NAME' created. What you got for free:
  - FastAPI app with /healthz, /readyz and /metrics (Prometheus)
  - Dockerfile (non-root, slim)
  - Helm chart that passes all platform policies
  - CI pipeline (tests, image build, GitOps tag bump)
  - Argo CD Application: gitops/apps/$NAME.yaml
  - Ingress at http://$NAME.localtest.me

Next: git add . && git commit -m "add $NAME" && git push
EOF

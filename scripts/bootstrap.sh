#!/usr/bin/env bash
# Creates a kind cluster, installs Argo CD, and hands control to GitOps.
# After this script, every change to the cluster should go through Git.
set -euo pipefail

CLUSTER="${1:-idp}"
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

for bin in docker kind kubectl helm; do
  command -v "$bin" >/dev/null || { echo "missing dependency: $bin"; exit 1; }
done

if ! kind get clusters | grep -qx "$CLUSTER"; then
  echo "==> Creating kind cluster '$CLUSTER'"
  kind create cluster --name "$CLUSTER" --config "$ROOT/cluster/kind-config.yaml"
fi

echo "==> Installing Argo CD"
helm repo add argo https://argoproj.github.io/argo-helm >/dev/null
helm repo update >/dev/null
helm upgrade --install argocd argo/argo-cd \
  --namespace argocd --create-namespace \
  --version 7.7.0 \
  --set configs.params."server\.insecure"=true \
  --wait

echo "==> Applying root app-of-apps (Argo CD now manages everything else)"
kubectl apply -f "$ROOT/gitops/bootstrap/root-app.yaml"

echo
echo "Done. Run 'make status' to watch components sync."
echo "Argo CD admin password:"
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d; echo

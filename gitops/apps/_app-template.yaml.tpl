# Used by scripts/new-service.sh. Argo CD ignores .tpl files.
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: __SERVICE_NAME__
  namespace: argocd
  labels:
    team: __TEAM__
  annotations:
    argocd.argoproj.io/sync-wave: "2"
spec:
  project: default
  source:
    repoURL: https://github.com/st8li/sample-platform.git
    targetRevision: main
    path: services/__SERVICE_NAME__/chart
  destination:
    server: https://kubernetes.default.svc
    namespace: __SERVICE_NAME__
  syncPolicy:
    automated: { prune: true, selfHeal: true }
    syncOptions: [CreateNamespace=true]

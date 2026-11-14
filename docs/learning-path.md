# Learning path: from sample to real platform

Work through these in order. Each one is a skill platform engineers are hired for.

## Level 1 – Operate it
1. Run `make up`, open Argo CD, and watch the sync waves: ingress + Kyverno (wave 0), then monitoring + policies (wave 1), then apps (wave 2).
2. **See GitOps self-heal:** `kubectl -n hello scale deploy hello --replicas=0`, then watch Argo CD put it back.
3. **See a guardrail fire:** `kubectl run bad --image=nginx:latest -n default` and read Kyverno's rejection message.
4. In Grafana, query `rate(http_requests_total[1m])` while you curl `hello.localtest.me` in a loop.

## Level 2 – Extend it
5. Add **cert-manager** as a new file in `gitops/platform/` and give the golden-path ingress TLS.
6. Write a Grafana dashboard as a ConfigMap (label `grafana_dashboard: "1"`) and ship it inside the chart, so every new service gets a dashboard on day one.
7. Move `run-as-nonroot` from `Audit` to `Enforce` after checking `kubectl get policyreports -A`. This is how you roll out a guardrail safely.
8. Add a second template (for example `templates/node-service`) and a `--lang` flag to `new-service.sh`.

## Level 3 – Make it a product
9. Replace the shell scaffolder with **Backstage** software templates plus a service catalog (`catalog-info.yaml` in each service).
10. Use **Argo CD ApplicationSets** (git directory generator) so you no longer need a file per service in `gitops/apps/`.
11. Provision real cloud infrastructure with **Terraform** or **Crossplane** (for example, a Postgres claim a developer can request in `values.yaml`).
12. Add multiple environments (dev/staging/prod) with promotion by pull request.
13. Measure the platform: DORA metrics (deploy frequency, lead time, change-failure rate, MTTR) and "time to first deploy" for a new service.

## Concepts to be able to explain in an interview
- Why GitOps (pull) instead of CI pushing to the cluster
- Golden paths vs. mandates; the "thinnest viable platform"
- Policy as code: admission control, audit before enforce
- Multi-tenancy: namespaces, RBAC, ResourceQuotas, NetworkPolicies
- Platform as a product: users, feedback, adoption metrics

CLUSTER ?= idp
REPO_URL ?= https://github.com/YOUR_USER/sample-platform.git

.PHONY: local-image up down status argocd-ui grafana-ui new-service repo-url lint test

up: ## Create cluster and bootstrap the platform
	./scripts/bootstrap.sh $(CLUSTER)

down: ## Delete the cluster
	kind delete cluster --name $(CLUSTER)

status: ## Show Argo CD application health
	kubectl -n argocd get applications

argocd-ui: ## Port-forward Argo CD and print admin password
	@echo "Password: $$(kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath='{.data.password}' | base64 -d)"
	kubectl -n argocd port-forward svc/argocd-server 8080:443

grafana-ui: ## Port-forward Grafana
	kubectl -n monitoring port-forward svc/monitoring-grafana 3000:80

new-service: ## Scaffold a service: make new-service NAME=payments
	./scripts/new-service.sh $(NAME)

repo-url: ## Point all Argo CD Applications at your fork
	./scripts/set-repo-url.sh $(REPO_URL)

test: ## Run the template's unit tests
	cd templates/python-service/app && python3 -m pytest -q

local-image: ## Build a service image and load it into kind (skip the registry): make local-image NAME=hello
	docker build -t ghcr.io/st8li/$(NAME):0.1.0 services/$(NAME)
	kind load docker-image ghcr.io/st8li/$(NAME):0.1.0 --name $(CLUSTER)

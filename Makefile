# Copyright 2024 Stefan Prodan.
# SPDX-License-Identifier: AGPL-3.0

# Makefile for deploying the Flux Operator on a Kubernetes KinD cluster
# using a local registry as the cluster desired state.

# Prerequisites:
# - Docker
# - Kind
# - Kubectl
# - Helm
# - Flux CLI

SHELL = /usr/bin/env bash -o pipefail
.SHELLFLAGS = -ec

.PHONY: all
all: up

##@ General

.PHONY: up
up: cluster-up flux-push flux-up ## Create the local cluster and registry, install Flux and the cluster addons

.PHONY: down
down: cluster-down ## Delete the local cluster and registry

.PHONY: sync
sync: flux-push flux-sync ## Build, push and reconcile the local manifests with the cluster

.PHONY: help
help: ## Display this help.
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n"} /^[a-zA-Z_0-9-]+:.*?##/ { printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2 } /^##@/ { printf "\n\033[1m%s\033[0m\n", substr($$0, 5) } ' $(MAKEFILE_LIST)

##@ Cluster

cluster-up: ## Creates a Kubernetes KinD cluster and a local registry bind to localhost:5050.
	./scripts/kind-up.sh

cluster-down: ## Shutdown the Kubernetes KinD cluster and the local registry.
	./scripts/kind-down.sh

##@ Artifacts

flux-push: ## Push the Kubernetes manifests to the local registry.
	./scripts/flux-push.sh

##@ Flux

flux-up: ## Deploy Flux Operator on the Kubernetes KinD cluster.
	./scripts/flux-up.sh

flux-sync: ## Sync the local cluster with the cluster.
	./scripts/flux-sync.sh

##@ Tools

tools: ## Install Kubernetes kind, kubectl, FLux CLI and Helm Homebrew
	brew bundle

## Location to install Go tools
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

# go-install-tool will 'go install' any package with custom target and name of binary, if it doesn't exist
# $1 - target path with name of binary (ideally with version)
# $2 - package url which can be installed
# $3 - specific version of package
define go-install-tool
@[ -f $(1) ] || { \
set -e; \
package=$(2)@$(3) ;\
echo "Downloading $${package}" ;\
GOBIN=$(LOCALBIN) go install $${package} ;\
mv "$$(echo "$(1)" | sed "s/-$(3)$$//")" $(1) ;\
}
endef

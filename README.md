# flux-operator-local-dev

[![test](https://github.com/controlplaneio-fluxcd/flux-operator-local-dev/actions/workflows/test.yaml/badge.svg)](https://github.com/controlplaneio-fluxcd/flux-operator-local-dev/actions/workflows/test.yaml)
[![license](https://img.shields.io/github/license/controlplaneio-fluxcd/flux-operator-local-dev.svg)](https://github.com/controlplaneio-fluxcd/flux-operator-local-dev/blob/main/LICENSE)

[Flux Operator](https://github.com/controlplaneio-fluxcd/flux-operator)
local dev environment with Docker and Kubernetes KIND.

## Get started

### Prerequisites

Start by cloning the repository locally:

```shell
git clone https://github.com/controlplaneio-fluxcd/flux-operator-local-dev.git
cd flux-operator-local-dev
```

The following tools are required:

- [Docker](https://docs.docker.com/get-docker/)
- [Kubernetes KIND](https://kind.sigs.k8s.io/docs/user/quick-start/)
- [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [Helm](https://helm.sh/docs/intro/install/)
- [Flux CLI](https://fluxcd.io/docs/installation/)

On macOS, you can install all the required tools with Homebrew by running:

```shell
make tools
```

### Bootstrap

Start the dev environment with:

```shell
make up
```

The `make up` command performs the following steps:
- creates the Docker registry container if it's not already running and exposes it on `localhost:5050`
- creates the Kubernetes Kind cluster if it's not already running
- pushes the Kubernetes manifests as OCI artifacts to the local registry
    - `locahost:5050/flux-cluster-sync` is generated from `kubernetes/clusters/local`
    - `locahost:5050/flux-infra-sync` is generated from `kubernetes/infra`
    - `locahost:5050/flux-apps-sync` is generated from `kubernetes/apps`
- installs Flux Operator on the cluster and configures it to reconcile the manifests from the local registry
- waits for Flux to reconcile the cluster addons from `oci://flux-registry:5000/flux-infra-sync`
- waits for Flux to reconcile the demo apps from `oci://flux-registry:5000/flux-apps-sync`

### Sync changes

To sync changes to the Kubernetes manifests, run:

```shell
make sync
```

The `make sync` command pushes the Kubernetes manifests to the local registry
and waits for Flux to reconcile the changes on the cluster.

### Tear down

To tear down the dev environment, run:

```shell
make down
```

The `make up` command deletes the Kind cluster and the Docker registry container.

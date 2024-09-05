# flux-operator-local-dev

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
make
```

The `make` command performs the following steps:
- creates the Docker registry container if it's not already running
- creates the Kubernetes Kind cluster if it's not already running
- pushes the Kubernetes manifests as OCI artifacts to the local registry
    - `locahost:5050/flux-cluster-sync` is generated from `kubernetes/clusters/local`
    - `locahost:5050/flux-infra-sync` is generated from `kubernetes/infra`
    - `locahost:5050/flux-apps-sync` is generated from `kubernetes/apps`
- installs Flux Operator on the clusters and configures it to reconcile the manifests from the local registry
- waits for Flux to reconcile the cluster addons from `oci://kind-registry:5000/flux-infra-sync`
- waits for Flux to reconcile the demo apps from `oci://kind-registry:5000/flux-apps-sync`

### Tear down

To tear down the dev environment, run:

```shell
make cluster-down
```

This command will delete the Kind cluster and the Docker registry container.

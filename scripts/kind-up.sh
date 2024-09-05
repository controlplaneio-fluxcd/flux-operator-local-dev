#!/usr/bin/env bash

# Copyright 2024 Stefan Prodan
# SPDX-License-Identifier: AGPL-3.0

set -o errexit

cluster_name="${CLUSTER_NAME:=flux}"
cluster_version="${CLUSTER_VERSION:=v1.31.0}"
reg_name="${cluster_name}-registry"
reg_localhost_port="5050"
reg_cluster_port="5000"

install_cluster() {
cat <<EOF | kind create cluster --name ${cluster_name} --wait 5m --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
containerdConfigPatches:
  - |-
    [plugins."io.containerd.grpc.v1.cri".registry.mirrors."localhost:${reg_localhost_port}"]
      endpoint = ["http://${reg_name}:${reg_cluster_port}"]
nodes:
  - role: control-plane
    image: kindest/node:${cluster_version}
    kubeadmConfigPatches:
      - |
        kind: InitConfiguration
        nodeRegistration:
          kubeletExtraArgs:
            node-labels: "ingress-ready=true"
  - role: worker
    image: kindest/node:${cluster_version}
EOF
}

register_registry() {
cat <<EOF | kubectl apply --server-side -f-
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_localhost_port}"
    hostFromContainerRuntime: "${reg_name}:${reg_cluster_port}"
    hostFromClusterNetwork: "${reg_name}:${reg_cluster_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF
}

# Create a registry container
if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
  echo "starting Docker registry on localhost:${reg_localhost_port}"
  docker run -d --restart=always -p "127.0.0.1:${reg_localhost_port}:${reg_cluster_port}" \
    --name "${reg_name}" registry:2
fi

# Create a cluster with the local registry enabled
if [ "$(kind get clusters | grep ${cluster_name})" != "${cluster_name}" ]; then
  install_cluster
  register_registry
else
  echo "cluster ${cluster_name} exists"
fi

# Connect the registry to the cluster network
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" = 'null' ]; then
  echo "connecting the Docker registry to the cluster network"
  docker network connect "kind" "${reg_name}"
fi

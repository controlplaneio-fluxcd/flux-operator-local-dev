#!/usr/bin/env bash

# Copyright 2024 Stefan Prodan
# SPDX-License-Identifier: AGPL-3.0

set -o errexit

cluster_name="${CLUSTER_NAME:=flux}"
reg_name="${cluster_name}-registry"

kind delete cluster --name ${cluster_name}

docker rm -f ${reg_name}

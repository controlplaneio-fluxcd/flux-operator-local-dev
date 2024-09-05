#!/usr/bin/env bash

# Copyright 2024 Stefan Prodan
# SPDX-License-Identifier: AGPL-3.0

set -o errexit

echo "Waiting for cluster addons sync to complete"
flux reconcile kustomization infra-controllers --with-source

echo "Waiting for apps sync to complete"
flux reconcile kustomization apps-sync --with-source
flux tree kustomization apps-sync

echo "✔ Cluster is in sync"

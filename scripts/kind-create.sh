#!/usr/bin/env bash
set -euo pipefail
CLUSTER_NAME="dev-env"
if kind get clusters | grep -q "^${CLUSTER_NAME}$"; then
  echo "✅ kind cluster ${CLUSTER_NAME} already exists"
  exit 0
fi
echo "⏳ Creating kind cluster ${CLUSTER_NAME} …"
kind create cluster --name "${CLUSTER_NAME}" --wait 60s

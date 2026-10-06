#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/minio" && pwd)"
IMAGE="local/minio:latest"

cd "$ROOT_DIR"
CGO_ENABLED=0 GOOS=linux GOARCH=amd64 \
  go build -tags kqueue -trimpath -o ./minio .

docker build --no-cache -t "$IMAGE" -f Dockerfile.local .

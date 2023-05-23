#/bin/bash

set -eu
REGISTRY_USER=$1
REGISTRY_PASSWORD=$2
IMAGE_REPOSITORY=ghcr.io/korvoj/wasm-serverless-benchmarks
IMAGE_NAME=wasmedge/go-aot-float-operation
IMAGE_TAG=v1.0.0
WASM_BINARY_PATH=float-operation.aot.wasm

ctr image pull --user $REGISTRY_USER:$REGISTRY_PASSWORD $IMAGE_REPOSITORY/$IMAGE_NAME:$IMAGE_TAG
ctr run --rm --runc-binary crun --runtime io.containerd.runc.v2 \
  --label module.wasm.image/variant=compat-smart \
  $IMAGE_REPOSITORY/$IMAGE_NAME:$IMAGE_TAG wasmedge-go-aot-float-operation /$WASM_BINARY_PATH 500

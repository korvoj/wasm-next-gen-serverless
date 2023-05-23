#!/bin/bash

set -e

AUTHFILE=~/.docker/config.json
IMAGE_REPOSITORY=ghcr.io/korvoj/wasm-serverless-benchmarks

if [ ! -z $1 ]
then
  echo "Single build mode..."
  MODE=$1
else
  echo "Building all images..."
fi

build_debian() {
  buildah build \
    -f Dockerfile.debian \
    --authfile $AUTHFILE \
    -t debian-rust-audio-sine-wave .

  buildah push \
    --authfile $AUTHFILE \
    debian-rust-audio-sine-wave \
    docker://$IMAGE_REPOSITORY/debian/rust-audio-sine-wave:v1.0.0
}

build_distroless() {
  buildah build \
    -f Dockerfile.distroless \
    --authfile $AUTHFILE \
    -t distroless-rust-audio-sine-wave .

  buildah push \
    --authfile $AUTHFILE \
    distroless-rust-audio-sine-wave \
    docker://$IMAGE_REPOSITORY/distroless/rust-audio-sine-wave:v1.0.0
}

build_wasmedge_jit() {
  buildah build \
    -f Dockerfile.wasmedge-jit \
    --authfile $AUTHFILE \
    --annotation "module.wasm.image/variant=compat-smart" \
    -t wasmedge-rust-jit-audio-sine-wave .

  buildah push \
    --authfile $AUTHFILE \
    wasmedge-rust-jit-audio-sine-wave \
    docker://$IMAGE_REPOSITORY/wasmedge/rust-jit-audio-sine-wave:v1.0.0
}

build_wasmedge_aot() {
  buildah build \
    -f Dockerfile.wasmedge-aot \
    --authfile $AUTHFILE \
    --annotation "module.wasm.image/variant=compat-smart" \
    -t wasmedge-rust-aot-audio-sine-wave .

  buildah push \
    --authfile $AUTHFILE \
    wasmedge-rust-aot-audio-sine-wave \
    docker://$IMAGE_REPOSITORY/wasmedge/rust-aot-audio-sine-wave:v1.0.0
}

build_wasmtime_jit() {
  buildah build \
    -f Dockerfile.wasmtime-jit \
    --authfile $AUTHFILE \
    --annotation "module.wasm.image/variant=compat-smart" \
    -t wasmtime-rust-jit-audio-sine-wave .

  buildah push \
    --authfile $AUTHFILE \
    wasmtime-rust-jit-audio-sine-wave \
    docker://$IMAGE_REPOSITORY/wasmtime/rust-jit-audio-sine-wave:v1.0.0
}

build_wasmtime_aot() {
  buildah build \
    -f Dockerfile.wasmtime-aot \
    --authfile $AUTHFILE \
    --annotation "module.wasm.image/variant=compat-smart" \
    -t wasmtime-rust-aot-audio-sine-wave .

  buildah push \
    --authfile $AUTHFILE \
    wasmtime-rust-aot-audio-sine-wave \
    docker://$IMAGE_REPOSITORY/wasmtime/rust-aot-audio-sine-wave:v1.0.0
}

build_wasmer_jit() {
  buildah build \
    -f Dockerfile.wasmer-jit \
    --authfile $AUTHFILE \
    --annotation "module.wasm.image/variant=compat-smart" \
    -t wasmer-rust-jit-audio-sine-wave .

  buildah push \
    --authfile $AUTHFILE \
    wasmer-rust-jit-audio-sine-wave \
    docker://$IMAGE_REPOSITORY/wasmer/rust-jit-audio-sine-wave:v1.0.0
}

build_wasmer_aot() {
  buildah build \
    -f Dockerfile.wasmer-aot \
    --authfile $AUTHFILE \
    --annotation "module.wasm.image/variant=compat-smart" \
    -t wasmer-rust-aot-audio-sine-wave .

  buildah push \
    --authfile $AUTHFILE \
    wasmer-rust-aot-audio-sine-wave \
    docker://$IMAGE_REPOSITORY/wasmer/rust-aot-audio-sine-wave:v1.0.0
}

if [ -z $MODE ]
then
  echo -n "Building a debian image..."
  build_debian
  echo -n "Building a distroless image..."
  build_distroless
  echo -n "Building for WasmEdge JIT..."
  build_wasmedge_jit
  echo -n "Building for WasmEdge AOT..."
  build_wasmedge_aot
  echo -n "Building for Wasmtime JIT..."
  build_wasmtime_jit
  echo -n "Building for Wasmtime AOT..."
  build_wasmtime_aot
  echo -n "Building for Wasmer JIT..."
  build_wasmer_jit
  echo -n "Building for Wasmer AOT..."
  build_wasmer_aot
else
case $MODE in
  debian)
    echo -n "Building a debian image..."
    build_debian
    ;;
  distroless)
    echo -n "Building a distroless image..."
    build_distroless
    ;;
  wasmedge-jit)
    echo -n "Building for WasmEdge JIT..."
    build_wasmedge_jit
    ;;
  wasmedge-aot)
    echo -n "Building for WasmEdge AOT..."
    build_wasmedge_aot
    ;;
  wasmtime-jit)
    echo "Building for WasmTime JIT..."
    build_wasmtime_jit
    ;;
  wasmtime-aot)
    echo "Building for WasmTime AOT..."
    build_wasmtime_aot
    ;;
  wasmer-jit)
    echo "Building for Wasmer JIT..."
    build_wasmer_jit
    ;;
  wasmer-aot)
    echo "Building for Wasmer AOT..."
    build_wasmer_aot
    ;;
  *)
    echo "Unsupported runtime. Please choose one from the following: debian, distroless, wasmedge-jit, wasmedge-aot, wasmtime-jit, wasmtime-aot, wasmer-jit, wasmer-aot"
    ;;
esac
fi

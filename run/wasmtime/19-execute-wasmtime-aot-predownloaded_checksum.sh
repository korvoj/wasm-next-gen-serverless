#!/bin/bash

REGISTRY_USER=$1
IMAGE_REPOSITORY=ghcr.io/korvoj/wasm-serverless-benchmarks
REGISTRY_PASSWORD=$2
TEST_NAME=checksum
IMAGE_NAME=wasmtime/go-aot-$TEST_NAME
IMAGE_TAG=v1.0.0
RUN_NAME=wasmtime-go-aot-$TEST_NAME
WASM_BINARY_PATH=checksum.aot.wasm

ITERATIONS=100

echo "Executing with wasmtime..."

rm -r /var/lib/containerd
tar -xzf /var/lib/containerd.tar.gz -C /var/lib
systemctl restart containerd
ctr image pull --user $REGISTRY_USER:$REGISTRY_PASSWORD $IMAGE_REPOSITORY/$IMAGE_NAME:$IMAGE_TAG
if [ -f /var/lib/containerd.$TEST_NAME.tar.gz ]
then
  rm /var/lib/containerd.$TEST_NAME.tar.gz
fi
tar -czf /var/lib/containerd.$TEST_NAME.tar.gz -C /var/lib containerd
sleep 10

for ((i=0;i<$ITERATIONS;i++))
do
  echo "Run $i..."
  rm -r /var/lib/containerd
  tar -xzf /var/lib/containerd.$TEST_NAME.tar.gz -C /var/lib
  systemctl restart containerd
  { /usr/bin/time -f '%e' ctr run --rm --runc-binary crun \
    --runtime io.containerd.runc.v2 \
    --label module.wasm.image/variant=compat-smart \
    --mount type=bind,src=../../sample-files/checksum,dst=/context,options=rbind:rw \
    $IMAGE_REPOSITORY/$IMAGE_NAME:$IMAGE_TAG $RUN_NAME \
    /$WASM_BINARY_PATH /context/cirros-0.6.0-x86_64-rootfs.img; } 2>> ../../results/wasmtime/aot/10-checksum.txt
  sleep 5
done

rm -r /var/lib/containerd
tar -xzf /var/lib/containerd.tar.gz -C /var/lib
systemctl restart containerd

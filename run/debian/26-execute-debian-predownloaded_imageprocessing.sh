REGISTRY_USER=$1
REGISTRY_PASSWORD=$2
TEST_NAME=imageprocessing
IMAGE_REPOSITORY=ghcr.io/korvoj/wasm-serverless-benchmarks
IMAGE_REPOSITORY=ghcr.io/korvoj/wasm-serverless-benchmarks
IMAGE_NAME=regular/go-$TEST_NAME
IMAGE_TAG=v1.0.0
RUN_NAME=regular-go-$TEST_NAME

ITERATIONS=100

echo "Executing with debian..."

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
  { /usr/bin/time -f '%e' ctr run --rm \
    --mount type=bind,src=../../sample-files/imageprocessing,dst=/context,options=rbind:rw \
    $IMAGE_REPOSITORY/$IMAGE_NAME:$IMAGE_TAG $RUN_NAME \
    /$TEST_NAME /context/example.jpg; } 2>> ../../results/debian/13-imageprocessing.txt
  rm ../../sample-files/imageprocessing/example.jpg-output.png
  sleep 5
done

rm -r /var/lib/containerd
tar -xzf /var/lib/containerd.tar.gz -C /var/lib
systemctl restart containerd

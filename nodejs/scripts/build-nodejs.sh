#!/bin/sh

# start docker daemon
dockerd  --host tcp://localhost:2375 &

dd if=/dev/zero of=/tmp/nodejs-runtime.ext4 bs=1M count=400
mkfs.ext4 /tmp/nodejs-runtime.ext4
mkdir /tmp/nodejs-runtime

mknod /dev/loop0 b 7 0 || true

while ! losetup -f; do
    sleep 1
done

mount /tmp/nodejs-runtime.ext4 /tmp/nodejs-runtime

max_retries=30 
retry_interval=1
i=1
while [ $i -le $max_retries ]; do
    docker run -i --rm \
        -v /tmp/nodejs-runtime:/nodejs-runtime \
        -v "/runtime:/runtime" \
        -v "/builder/scripts/openrc-service.sh:/etc/init.d/runtime" \
        node:alpine sh </builder/scripts/setup-alpine.sh 
    
    if [ $? -eq 0 ]; then
        echo "Command succeeded on attempt $i"
        break
    fi

    echo "Retry $i/$max_retries. Waiting $retry_interval seconds before retrying..."
    sleep $retry_interval
    i=$((i + 1))
done
umount /tmp/nodejs-runtime
rm -rf /tmp/nodejs-runtime

aws s3 cp /tmp/nodejs-runtime.ext4 $S3_URI/rootfs/nodejs-runtime/nodejs-runtime.ext4
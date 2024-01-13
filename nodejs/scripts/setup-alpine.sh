#!/bin/sh

set -xeo

apk add --no-cache openrc
apk add --no-cache curl
apk add --no-cache util-linux

ln -s agetty /etc/init.d/agetty.ttyS0
echo ttyS0 >/etc/securetty
rc-update add agetty.ttyS0 default

echo "root:root" | chpasswd

echo "nameserver 8.8.8.8" >> /etc/resolv.conf

chmod +x /etc/init.d/runtime

rc-update add devfs boot
rc-update add procfs boot
rc-update add sysfs boot

rc-update add runtime boot

echo "/dev/vdb        /tmp            ext4    defaults  0 2" >> /etc/fstab

for d in bin etc lib root sbin usr runtime; do tar c "/$d" | tar x -C /nodejs-runtime; done
for dir in dev proc run sys var tmp; do mkdir /nodejs-runtime/${dir}; done

chmod 1777 /nodejs-runtime/tmp
mkdir -p /nodejs-runtime/home/nodejs-runtime/
chown 1000:1000 /nodejs-runtime/home/nodejs-runtime/
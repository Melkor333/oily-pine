#!/usr/bin/env sh
# Install build deps, oils and set up a build user

set -ex

# oils-* is only in the testing repos...
echo https://dl-cdn.alpinelinux.org/alpine/edge/testing >> /etc/apk/repositories
apk add abuild abuild-rootbld doas build-base alpine-sdk oils-for-unix oils-for-unix-binsh oils-for-unix-bash lua-aports
sed -i '/testing/d' /etc/apk/repositories

echo 'permit nopass :wheel' > /etc/doas.conf

adduser -Du 1000 packager
adduser packager abuild
adduser packager wheel
su packager -c "abuild-keygen -na --install"
mkdir -p /home/packager/aports
mkdir -p /home/packager/packages
chown -R packager /home/packager

apk cache clean --purge

rm /bin/ash
ln -s /usr/bin/oils-for-unix /bin/ash

## TODO: For testing
#echo '/packages/main' > /etc/apk/repositories
#echo '/packages/community' >> /etc/apk/repositories
#echo '/packages/testing' >> /etc/apk/repositories

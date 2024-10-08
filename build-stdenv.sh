#!/usr/bin/env sh
# Run this inside of:
# podman run -ti --rm --mount "type=bind,source=./,target=/aports" alpine /aports/build-all.sh

set -ex

APORTSDIR=/aports

# TODO: remove when building with packager user only
cp -R /aports/build/abuild /root/.abuild
cp -R /aports/build/abuild/-66b5b4e2.rsa.pub /etc/apk/keys
cp -R /aports/build/abuild/-66b5b4e5.rsa.pub /etc/apk/keys
mkdir -p /aports/repo

cd /aports

apk add abuild-rootbld


# Set up the package user
apk add doas build-base alpine-sdk
# create a packager user and add him to sudo list
adduser -Du 1000 packager
addgroup packager abuild
echo "permit nopass packager" >> /etc/doas.conf
doas -C /etc/doas.conf
su packager -c "abuild-keygen -na --install"

for pkg in oils-for-unix readline; do
  cd main/$pkg
  # TODO: mount with UID
  abuild -rF -s /tmp
  cd -
done
#su packager -c "abuild -r"


echo '/aports/repo/main' > /etc/apk/repositories
echo '/aports/repo/community' >> /etc/apk/repositories
#echo '/aports/repo/testing' >> /etc/apk/repositories
apk cache clean --purge

apk add oils-for-unix

# TODO: all the required packages to have a running system
# Not sure what is really required
#files="
#  musl
#  ncurses
#  readline
#"
#
#for file in $files; do
#  cd /aports/main/$file
#  abuild -Fr
#done

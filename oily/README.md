# Oily Alpine!

Building all alpine packages with oils-for-unix instead of busybox ash or bash.

This should work with either `podman` or `docker`.

Warning: For now `--usermode=keep-id` is not configured in the scripts, so the container might change the permissions of local files!

## Usage

`./build-container.sh` sets up an alpine container with a build user and installs Oils to /bin/sh and /bin/bash.
`./build-packages.sh` runs the container with the following 4 mount points and build packages:
- ../ -> The package sources (/home/packager/aports)
- ./abuild -> The gpg key and abuild config is stored (and reused) from here (/home/packager/.abuild)
- ./packages -> That's where the built packages will go (/home/packager/packages)
- ./logs -> Logs will be put here (/home/packager/logs)

`./hacking.sh` start a container to manually build packages, etc.

`./find-broken.sh` Finds `src` directories of unfinished package builds which are most certainly failed builds. If there is a running build container, it also detects the current unfinished package build.

## the package build script

The file `./package.sh` is invoked in the container to build all the packages.
If first invokes `./setup-key.sh` which generates an signing key or copies an existing key to `/etc/apk/keys`
Afterwards it just calls `buildrepo` which does a recursive build.

## TODO

Replace all `bash` requirements with `/bin/bash`.

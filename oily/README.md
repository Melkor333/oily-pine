# Oily Alpine!

Building all alpine packages with oils-for-unix instead of busybox ash or bash.

## Usage

`./build-container.sh` sets up an alpine container with a build user and installs Oils to /bin/sh and /bin/bash.

`./package.sh` runs the container with 3 mount points:
- ../ -> The package sources
- ./abuild -> The gpg key and abuild config is stored (and reused) from here
- ./packages -> That's where the built packages will go

`./container/build.sh` does the actual building of packages.
It generates a key if necessary and then just calls `buildrepo` which does a recursive build.

## TODO

Replace all `bash` requirements with `/bin/bash`.

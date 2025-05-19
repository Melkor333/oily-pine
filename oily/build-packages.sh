#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR/"
cd ..

runtime=$(command -v podman || command -v docker)

# This is an example on how to build packages using the container
# It's relevant that the proper directories are mounted
$runtime run --rm -v ./:/home/packager/aports -v ./oily/abuild:/home/packager/.abuild -v ./oily/logs:/home/packager/logs -v ./oily/packages:/home/packager/packages oily-pine-builder $@ |& tee -a oily/logs/$(date +%y-%m-%d_%H:%M)-buildrepo.log

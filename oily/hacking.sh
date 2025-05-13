#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR/"
cd ..

# This is an example on how to build packages using the container
# It's relevant that the proper directories are mounted
podman run --rm -ti -v ./:/home/packager/aports -v ./oily/logs:/home/packager/logs -v ./oily/abuild:/home/packager/.abuild -v ./oily/packages:/home/packager/packages --userns keep-id --entrypoint /usr/bin/ysh oily-pine-builder $@

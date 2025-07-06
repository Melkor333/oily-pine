#!/usr/bin/env bash

set -eo pipefail


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
	cd "$SCRIPT_DIR/.."
CONTAINER="oily-pine-builder"
RUNTIME=$(command -v podman || command -v docker)
MOUNTPOINTS="-v ./:/home/packager/aports -v ./oily/abuild:/home/packager/.abuild -v ./oily/logs:/home/packager/logs -v ./oily/packages:/home/packager/packages"


build() {
  if test -n "$1"; then
    sed -i "s|^wget .*|wget $1|" oily/container/install-dirty-oils.sh
  fi

  $RUNTIME build oily/container/ -t $CONTAINER
}

package() {
  if test -z "$1"; then
    $RUNTIME run --rm $MOUNTPOINTS $CONTAINER $@ |& tee -a oily/logs/$(date +%y-%m-%d_%H:%M)-buildrepo.log
  else
    $RUNTIME run --rm $MOUNTPOINTS --entrypoint /usr/bin/ysh $CONTAINER \
    -c "/home/packager/aports/oily/setup-key.sh; abuild -rC 'aports/$1'"
  fi
}

hack() {
  echo "once in the container, run /home/packager/aports/oily/setup-key.sh before packaging"
  $RUNTIME run --rm -ti $MOUNTPOINTS --entrypoint /usr/bin/ysh $CONTAINER $@
}

usage() {
  echo '
build [URL]               Build the container.
                          if URL is given, install oils from this tarball.
                          The URL *must* be a `.tar` url (cannot be a .tar.gz release tarball!)
                          Example:
                          https://op.oilshell.org/uuu/github-jobs/9569/cpp-tarball.wwz/_release/oils-for-unix.tar

package [PACKAGENAME]     Build a package. If no package given, try to build all packages
                          A package must contain the repository name, e.g. `main/bash`

hack                      Start a container to hack on things
'
}

help() {
  usage
}

if test -z "$*"; then
  echo "need at least 1 argument"
  usage
  exit 1
fi
$@

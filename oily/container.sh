#!/usr/bin/env bash

set -eo pipefail


SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR/.."
CONTAINER="oily-pine-builder"
RUNTIME=$(command -v podman || command -v docker || { echo 'need docker or podman' >&2 ; exit 1; })
echo "using '$RUNTIME'"
MOUNTPOINTS="-v ./:/home/packager/aports -v ./oily/abuild:/home/packager/.abuild -v ./oily/logs:/home/packager/logs -v ./oily/packages:/home/packager/packages"
RUN_ARGS="--rm"
if [[ "$RUNTIME" =~ .*"podman" ]]; then
  RUN_ARGS="$RUN_ARGS --userns=keep-id:uid=1000,gid=1000"
fi


build() {
  if test -n "$1"; then
    sed -i "s|^wget .*|wget $1|" oily/container/install-dirty-oils.sh
  fi

  $RUNTIME build --network=host oily/container/ -t $CONTAINER
}

package() {
  if test -z "$1"; then
    $RUNTIME run $RUN_ARGS $MOUNTPOINTS $CONTAINER $@ |& tee -a oily/logs/$(date +%y-%m-%d_%H:%M)-buildrepo.log
  else
    $RUNTIME run $RUN_ARGS $MOUNTPOINTS --entrypoint /usr/bin/ysh $CONTAINER \
    -c "/home/packager/aports/oily/setup-key.sh; abuild -rC 'aports/$1'"
  fi
}

hack() {
  echo "once in the container, run /home/packager/aports/oily/setup-key.sh before packaging"
  $RUNTIME run $RUN_ARGS -ti $MOUNTPOINTS --entrypoint /usr/bin/ysh $CONTAINER $@
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

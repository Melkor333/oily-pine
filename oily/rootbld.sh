#!/usr/bin/env bash

set -eo pipefail
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

TEST_PACKAGE="main/bash"
doc="
This script expects a folder $HOME/aports/testing/oils-for-unix/ containing an APKBUILD.
Instead of using abuild to fetch sources, it will fetch sources from the Oils CI.
It uses abuild to build and package the sources.
The apks are then installed to $HOME/packages/testing/x86_64/

prepare-system        prepare the system to run rootbld builds with Oils

build [URL]           Build an oils-for-unix.apk used for later packaging
                      if no URL is given, just build the existing APKBUILD.
                      Otherwise fetch the URL - which needs to be
                      from the Oils CI! Official tarballs are a different
                      format and don't work here.
                      Change the APKBUILD file in case of a new release.

package [PACKAGE]     Build a package. If no package given, try to build all
                      packages
                      A package must contain the repository name, e.g. 'main/bash'
"

die() {
  echo "$@"
  echo "$doc"
  exit 1
}

build() {
  if [[ -z "$1" ]]; then
    cleanup-existing-oils
    cd $HOME/aports/testing/oils-for-unix
    abuild -r
  else
    prepare-oils "$1"
    build-oils
    package-oils
  fi
}

prepare-system() {
  cd $HOME

  if ! [[ -L aports ]]; then
    rmdir aports 2>/dev/null || true
    ln -vs $(realpath "$SCRIPT_DIR/..") aports
  fi
  if ! [[ -L packages ]]; then
    rmdir packages 2>/dev/null || true
    ln -vs "$SCRIPT_DIR/packages" packages
  fi
  if ! which buildrepo-oils >/dev/null; then
    doas cp -v rootbld/buildrepo-oils /usr/bin/
  fi
  if ! which abuild-oils >/dev/null; then
    doas cp -v rootbld/abuild-oils /usr/bin/
  fi
}

# Download a oils tarball and unpack it, requires URL of a .tar
prepare-oils() {
  test -n "$1" || die "Need a oils download url as argument"

  cd "$HOME/aports/testing/oils-for-unix"
  test -d src && mv src src.$(date -Iminutes)
  mkdir src
  cd src
  wget "$1"
  tar xvf *.tar
  rm *tar
  (source ../APKBUILD; mv * oils-for-unix-$pkgver)
}

# Run the oils 'build' step (configure and _oils/build.sh)
build-oils() {
  cd /home/packager/aports/testing/oils-for-unix
  abuild build
}

cleanup-existing-oils() {
  rm -r "$HOME/packages/testing/x86_64/oils-for-unix-"* || true
}

# Delete existing oils packages, run the './install' phase and
# create a new .apk
package-oils() {
  cd "$HOME/aports/testing/oils-for-unix"

  test -d pkg && mv pkg pkg.$(date -Iminutes)
  cleanup-existing-oils

  abuild package rootpkg index
}

package() {
  if test -z "$1"; then
    "$SCRIPT_DIR/rootbld/package.sh" |& tee "$SCRIPT_DIR/logs/$(date +%y-%m-%d_%H:%M)-buildrepo.log"
  else
    cd "$HOME/aports/$1"
    abuild-oils rootbld
  fi
}

# --------

test -n "$1" || die "Need a function to execute:"
dir="$HOME/aports/testing/oils-for-unix"
test -d "$dir" || die "need directory/symlink $dir"
dir="$HOME/packages"
test -d "$dir" || die "need directory/symlink $dir"

$@

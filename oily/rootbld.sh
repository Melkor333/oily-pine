#!/usr/bin/env bash
set -e
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

TEST_PACKAGE="zip"
doc="
This script expects a folder $HOME/aports/testing/oils-for-unix/ containing an APKBUILD.
Instead of using abuild to fetch sources, it will fetch sources from the Oils CI.
It uses abuild to build and package the sources.
The apks are then installed to $HOME/packages/testing/x86_64/

all URL [PACKAGE]	 Run all of the below steps in order

oils URL                 Run the below 3 phases to create a pils-for-unix.apk

prepare-oils URL         Download a oils tarball and unpack it, requires URL of a .tar

build-oils               Run the oils 'build' step (configure and _oils/build.sh)
			 uses 'abuild' phases

package-oils             Delete existing packages, run the './install' phase and
                         create a new .apk
			 uses 'abuild' phases

package [PACKAGE]        Try to build PACKAGE (default: $TEST_PACKAGE) with a
                         previously built oils as /bin/sh *in a rootbld* ('abuild-oils rootbld')
             	         This depends on the file
	     	         $HOME/aports/main/.rootbld-repositories
	     	         containing the line line:
	     	         $HOME/packages/testing/
"

die() {
  echo "$@"
  echo "$doc"	  
  exit 1
}

all() {
  oils "$1"
  package "$2"
}

oils() {
  prepare-oils "$1"
  build-oils
  package-oils
}

prepare-vm() {
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

build-oils() {
  cd /home/packager/aports/testing/oils-for-unix
  abuild build
}

package-oils() {
  cd "$HOME/aports/testing/oils-for-unix"
  
  test -d pkg && mv pkg pkg.$(date -Iminutes)
  rm -r "$HOME/packages/testing/x86_64/oils-for-unix-"* || true
  
  abuild package rootpkg index
}

package() {
  if test -n "$1"; then
    TEST_PACKAGE="$1"
  fi
  cd "$HOME/aports/main/$TEST_PACKAGE"

  abuild-oils rootbld
}

buildrepo() {
  time "$SCRIPT_DIR/rootbld/package.sh" |& tee "$SCRIPT_DIR/logs/$(date +%y-%m-%d_%H:%M)-buildrepo.log"
}

# --------

test -n "$1" || die "Need a function to execute:"
dir="$HOME/aports/testing/oils-for-unix"
test -d "$dir" || die "need directory/symlink $dir"
dir="$HOME/packages"
test -d "$dir" || die "need directory/symlink $dir"

$@

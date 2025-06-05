#!/usr/bin/env bash
set -e

TEST_PACKAGE="zip"
doc="
This script expects a folder $HOME/aports/testing/oils-for-unix/ containing an APKBUILD.
Instead of using abuild to fetch sources, it will fetch sources from the Oils CI.
It uses abuild to build and package the sources.
The apks are then installed to $HOME/packages/testing/x86_64/

all URL [PACKAGE]   Run all of the below steps in order

prepare URL         Download a oils tarball and unpack it, requires URL of a .tar

build               Run the oils 'build' step (configure and _oils/build.sh)

package             Delete existing packages, run the './install' phase and
                    create a new .apk

execute [PACKAGE]   Try to build PACKAGE (default: $TEST_PACKAGE) with a
                    previously build oils as /bin/sh ('abuild-oils rootbld')
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
  prepare "$1"
  build
  package
  execute "$2"
}

prepare() {
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

build() {
  cd /home/packager/aports/testing/oils-for-unix
  abuild build
}

package() {
  cd "$HOME/aports/testing/oils-for-unix"
  
  test -d pkg && mv pkg pkg.$(date -Iminutes)
  rm -r "$HOME/packages/testing/x86_64/oils-for-unix-"* || true
  
  abuild package rootpkg index
  
}

execute() {
  if test -n "$1"; then
    TEST_PACKAGE="$1"
  fi
  cd "$HOME/aports/main/$TEST_PACKAGE"

  abuild-oils rootbld
}

# --------

test -n "$1" || die "Need a function to execute:"
dir="$HOME/aports/testing/oils-for-unix"
test -d "$dir" || die "need directory/symlink $dir"
dir="$HOME/packages"
test -d "$dir" || die "need directory/symlink $dir"

$@

#!/usr/bin/env bash

set -e

# to have readline!
doas apk add readline-dev

mkdir build
cd build

wget http://op.oilshell.org/uuu/github-jobs/10248/cpp-tarball.wwz/_release/oils-for-unix.tar

tar xvf oils-for-unix.tar
rm oils-for-unix.tar
cd oils-*
./configure --prefix /usr
_build/oils.sh
doas ./install

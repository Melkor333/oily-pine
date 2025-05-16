#!/usr/bin/env bash

mkdir build
cd build

wget https://op.oilshell.org/uuu/github-jobs/9515/cpp-tarball.wwz/_release/oils-for-unix.tar

tar xvf oils-for-unix.tar
rm oils-for-unix.tar
cd oils-*
./configure --prefix /usr
_build/oils.sh
doas ./install

#!/usr/bin/env bash
# Generate key or reuse key
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

../setup-key.sh

buildrepo-oils -Rk -l "$HOME/logs" $@ main
buildrepo-oils -Rk -l "$HOME/logs" $@ community
buildrepo-oils -Rk -l "$HOME/logs" $@ testing

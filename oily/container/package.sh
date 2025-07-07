#!/usr/bin/env bash
# Generate key or reuse key
set -e

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

../setup-key.sh

buildrepo -k -l "$HOME/logs" $@ main
buildrepo -k -l "$HOME/logs" $@ community
buildrepo -k -l "$HOME/logs" $@ testing

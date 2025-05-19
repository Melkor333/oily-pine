#!/usr/bin/env bash

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
cd "$SCRIPT_DIR"

runtime=$(command -v podman || command -v docker)

$runtime build container/ -t oily-pine-builder

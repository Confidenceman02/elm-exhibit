#!/usr/bin/env bash
set -eo pipefail

echo "Checking ts files"
yarn tsc --noEmit

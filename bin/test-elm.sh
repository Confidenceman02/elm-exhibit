#!/usr/bin/env bash
set -eo pipefail

echo "Testing elm"
yarn elm-test

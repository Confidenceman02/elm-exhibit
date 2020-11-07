#!/usr/bin/env bash
set -eo pipefail

echo "Testing ts"
yarn mocha --inline-diffs -r ts-node/register 'tests/**/*.ts'

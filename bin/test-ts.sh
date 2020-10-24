#!/usr/bin/env bash
set -eo pipefail

echo "Testing ts"
yarn mocha -r ts-node/register 'tests/**/*.ts'



#!/usr/bin/env bash
set -eo pipefail

echo "Testing js"
yarn mocha -r ts-node/register 'tests/**/*.ts'


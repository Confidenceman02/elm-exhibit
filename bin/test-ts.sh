#!/usr/bin/env bash
set -eo pipefail

echo "Testing ts"
yarn mocha --exit --require tests/mocha.env.ts -r ts-node/register 'tests/**/*.spec.ts'

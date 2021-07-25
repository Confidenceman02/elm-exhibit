#!/usr/bin/env bash
set -eo pipefail

echo "Building lib"
yarn tsc lib/**/*.ts

echo "Building lambda functions"
npx babel --extensions '.ts' ./functions -d built-lambda

echo "Starting netlify local server"
ntl dev

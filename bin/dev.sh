#!/usr/bin/env bash
set -eo pipefail

echo "Building lambda functions"
npx babel --extensions '.ts' ./functions -d built-lambda
echo "Building lib"
npx babel --extensions '.ts' ./lib -d lib

echo "Starting netlify local server"
ntl dev

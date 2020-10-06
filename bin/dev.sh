#!/usr/bin/env bash
set -eo pipefail

yarn build:lambda && ntl dev

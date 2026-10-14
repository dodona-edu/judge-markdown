#!/usr/bin/env bash
# Runs devel/run-tests.sh as root inside the judge image.
#
#   IMAGE=...           judge image (default ghcr.io/dodona-edu/dodona-java:latest)
#   UPDATE_EXPECTED=1   rewrite the expected output

set -euo pipefail

repo="$(cd "$(dirname "$0")/.." && pwd)"

docker run --rm --platform linux/amd64 --user root \
  ${UPDATE_EXPECTED:+--env UPDATE_EXPECTED} \
  --volume "$repo:/judge-markdown" \
  --workdir /judge-markdown \
  "${IMAGE:-ghcr.io/dodona-edu/dodona-java:latest}" \
  devel/run-tests.sh

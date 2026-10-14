#!/bin/sh
set -eu

cd "$(dirname "$0")/.."

shellcheck run devel/*.sh

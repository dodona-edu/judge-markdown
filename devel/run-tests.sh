#!/bin/sh
# Runs the judge on every tests/cases/*.md and compares its feedback with
# tests/expected/<case>.json. Meant to run as root inside the judge image, like
# CI; devel/run-tests-in-image.sh does that locally. A case named <name>.nl.md
# runs with Dutch as natural language, the others with English.
#
#   UPDATE_EXPECTED=1   rewrite the expected output

set -u

repo=$(cd "$(dirname "$0")/.." && pwd)
root=

# Dodona mounts everything under /mnt/<random>/
if ! [ -w /mnt ]; then
  echo "/mnt is not writable: run the suite as root, like CI" >&2
  exit 2
fi

cleanup() {
  [ -n "$root" ] && rm -rf "$root"
  root=
}
trap cleanup EXIT
trap 'exit 130' INT TERM

passed=0
failed=0

for source in "$repo"/tests/cases/*.md; do
  name=${source##*/}
  name=${name%.md}
  expected=$repo/tests/expected/$name.json

  case $name in
    *.nl) language="nl" ;;
    *) language="en" ;;
  esac

  root=$(mktemp -d -p /mnt) || exit 2
  mkdir "$root/resources" "$root/submission" "$root/workdir"
  cp "$source" "$root/submission/source"

  jq --null-input \
    --arg source "$root/submission/source" \
    --arg language "$language" \
    --arg judge "$repo" \
    --arg resources "$root/resources" \
    --arg workdir "$root/workdir" \
    '{
      source: $source,
      natural_language: $language,
      judge: $judge,
      resources: $resources,
      workdir: $workdir,
      programming_language: "markdown",
      time_limit: 10,
      memory_limit: 536870912
    }' > "$root/config.json"

  (cd "$root/workdir" && /main.sh "$repo/run" < "$root/config.json") \
    > "$root/stdout" 2> "$root/stderr"
  exit_code=$?

  if jq --slurp \
    --argjson exit_code "$exit_code" \
    --rawfile stderr "$root/stderr" \
    '{exit_code: $exit_code, stderr: $stderr, feedback: .}' \
    "$root/stdout" > "$root/actual.json"; then
    :
  else
    echo "FAIL $name: judge output is not a JSON stream"
    cat "$root/stdout"
    failed=$((failed + 1))
    cleanup
    continue
  fi

  if [ "${UPDATE_EXPECTED:-}" = 1 ]; then
    mkdir -p "$repo/tests/expected"
    cp "$root/actual.json" "$expected"
    echo "UPDATED $name"
    passed=$((passed + 1))
  elif ! [ -f "$expected" ]; then
    echo "FAIL $name: missing $expected (run with UPDATE_EXPECTED=1)"
    failed=$((failed + 1))
  elif diff -u "$expected" "$root/actual.json" > "$root/diff"; then
    echo "PASS $name"
    passed=$((passed + 1))
  else
    echo "FAIL $name"
    cat "$root/diff"
    failed=$((failed + 1))
  fi

  cleanup
done

echo
echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ]

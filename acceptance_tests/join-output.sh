#!/bin/bash

setUp() {
  join_tmp=$(mktemp -d)
}

tearDown() {
  rm -rf "$join_tmp"
}

assertJoinedOutput() {
  local expected="$1"
  shift
  "$@" > "$join_tmp/actual"
  assertEquals "command succeeds" 0 "$?"
  printf '%s' "$expected" > "$join_tmp/expected"
  cmp "$join_tmp/expected" "$join_tmp/actual"
  assertEquals "exact output bytes" 0 "$?"
}

testJoinScalars() {
  assertJoinedOutput 'foobar' ./yq -n --join-output '"foo", "bar"'
}

testPreserveValueNewlines() {
  assertJoinedOutput $'foo\n\nbar\n' ./yq -n --join-output '"foo\n\n", "bar\n"'
}

testPreserveCarriageReturn() {
  assertJoinedOutput $'foo\r' ./yq -n --join-output '"foo\r"'
}

testJoinJSONRawStrings() {
  assertJoinedOutput 'foobar' ./yq -n -o=json -r --join-output '"foo", "bar"'
}

testKeepJSONQuotes() {
  assertJoinedOutput '"foo""bar"' ./yq -n -o=json --join-output '"foo", "bar"'
}

testJoinEmptyAndNull() {
  assertJoinedOutput 'null' ./yq -n --join-output '"", null, ""'
}

testJoinMultipleDocuments() {
  printf 'foo\n---\nbar\n' > "$join_tmp/input.yml"
  assertJoinedOutput 'foobar' ./yq --join-output '.' "$join_tmp/input.yml"
}

testJoinEvalAll() {
  printf 'foo\n---\nbar\n' > "$join_tmp/input.yml"
  assertJoinedOutput 'foobar' ./yq ea --join-output '.' "$join_tmp/input.yml"
}

testJoinJSONContainers() {
  assertJoinedOutput '{"a":1}{"b":2}' ./yq -n -o=json -I=0 --join-output '{"a": 1}, {"b": 2}'
}

testJoinNoMatches() {
  assertJoinedOutput '' ./yq -n --join-output 'select(false)'
}

testJoinMultipleFiles() {
  printf 'foo\n' > "$join_tmp/first.yml"
  printf 'bar\n' > "$join_tmp/second.yml"
  assertJoinedOutput 'foobar' ./yq --join-output '.' "$join_tmp/first.yml" "$join_tmp/second.yml"
}

testJoinNulFlagsConflict() {
  ./yq -n --join-output --nul-output '"foo"' > "$join_tmp/actual" 2> "$join_tmp/error"
  assertNotEquals 0 "$?"
  assertContains "$(cat "$join_tmp/error")" 'join-output cannot be used with nul-output'
}

source ./scripts/shunit2

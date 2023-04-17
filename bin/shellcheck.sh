#!/usr/bin/env bash

# Runs Shellcheck
# Requires https://github.com/koalaman/shellcheck

set -e

if ! command -v shellcheck >/dev/null 2>&1; then
  echo "Error: shellcheck not found"
  exit 1
fi

echo "Running pre-commit checks..."
shellcheck "${@}"

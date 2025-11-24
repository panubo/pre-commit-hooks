#!/usr/bin/env bash

# LICENSE: The MIT License Copyright (c) 2025 Volt Grid Pty Ltd t/a Panubo

# Runs Terraform Lint

set -e

if ! command -v tofu >/dev/null 2>&1; then
  echo "Error: tofu not found"
  exit 1
fi

echo "Running $(basename "${0}") pre-commit checks..."
for FILE in "${@}"; do
  pushd "$(dirname "${FILE}")"
  tofu providers lock -platform=linux_amd64
  popd
done

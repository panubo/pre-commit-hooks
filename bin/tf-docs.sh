#!/usr/bin/env bash

# LICENSE: The MIT License Copyright (c) 2025 Volt Grid Pty Ltd t/a Panubo

# Runs Terraform Docs

set -e

if ! command -v terraform-docs >/dev/null 2>&1; then
  echo "Error: terraform-docs not found"
  exit 1
fi

echo "Running $(basename "${0}") pre-commit checks..."
for FILE in "${@}"; do
  DIR=$(dirname "${FILE}")
  if [ -e "${DIR}/README.md" ]; then
    terraform-docs markdown "$(dirname "${FILE}")" >/dev/null
  fi
done

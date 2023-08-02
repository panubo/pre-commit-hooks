#!/usr/bin/env bash

# LICENSE: The MIT License Copyright (c) 2023 Volt Grid Pty Ltd t/a Panubo

# Runs Terraform Lint
# Requires https://github.com/terraform-linters/tflint

set -e

if ! command -v tflint >/dev/null 2>&1; then
  echo "Error: tflint not found"
  exit 1
fi

echo "Running pre-commit checks..."
for FILE in "${@}"; do
  tflint --filter="${FILE}"
done

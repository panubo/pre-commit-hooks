#!/usr/bin/env bash

# Runs Terraform Lint
# Requires https://github.com/terraform-linters/tflint

set -e

if ! command -v tflint >/dev/null 2>&1; then
  echo "Error: tflint not found"
  exit 1
fi

echo "Running pre-commit checks..."
for FILE in "${@}"; do
  tflint "${FILE}"
done

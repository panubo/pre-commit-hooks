#!/usr/bin/env bash

# Runs Terraform Lint
# Requires https://github.com/terraform-linters/tflint

set -e

echo "Running pre-commit checks..."
for FILE in "${@}"; do
  tflint "${FILE}"
done

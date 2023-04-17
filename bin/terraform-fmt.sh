#!/usr/bin/env bash

# Runs Terraform Format

set -e

echo "Running pre-commit checks..."
for FILE in "${@}"; do
  terraform fmt "${FILE}"
done

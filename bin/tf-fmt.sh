#!/usr/bin/env bash

# LICENSE: The MIT License Copyright (c) 2023,2025 Volt Grid Pty Ltd t/a Panubo

# Runs Tofu or Terraform Format

set -e

if command -v tofu &> /dev/null; then
  TF_CMD='tofu'
elif command -v terraform &> /dev/null; then
  TF_CMD='terraform'
else
  echo "Error: Neither 'tofu' nor 'terraform' found in PATH." >&2
  exit 1
fi

echo "Running pre-commit checks..."
for FILE in "${@}"; do
  ${TF_CMD} fmt "${FILE}"
done

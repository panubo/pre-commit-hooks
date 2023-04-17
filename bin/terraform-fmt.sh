#!/usr/bin/env bash

# LICENSE: The MIT License Copyright (c) 2023 Volt Grid Pty Ltd t/a Panubo

# Runs Terraform Format

set -e

echo "Running pre-commit checks..."
for FILE in "${@}"; do
  terraform fmt "${FILE}"
done

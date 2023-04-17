#!/usr/bin/env bash

# Runs Terraform Format

set -e

echo "Running pre-commit checks..."

terraform fmt "$@"

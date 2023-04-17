#!/usr/bin/env bash

# LICENSE: The MIT License Copyright (c) 2023 Volt Grid Pty Ltd t/a Panubo

# Checks that Ansible secret files (secret.yml) are actually encrypted

set -e

is_encrypted() {
  local file=$1
  if ! git show :"$file" | grep --quiet "^\$ANSIBLE_VAULT"; then
    echo "Unencrypted file detected!"
    exit 1
  fi
}

echo "Running pre-commit checks..."
for FILE in "${@}"; do
  git diff --cached --name-only | grep "${FILE}" | while IFS= read -r line; do
    is_encrypted "${line}"
  done
done

#!/usr/bin/env bash

# LICENSE: The MIT License Copyright (c) 2025 Volt Grid Pty Ltd t/a Panubo

# This script checks for local Terraform module references (e.g., source = "../modules/foo").
#
# Control behavior with the TF_LOCAL_MODULE_ACTION environment variable:
# - TF_LOCAL_MODULE_ACTION=warn: Prints warnings but allows the commit.
# - TF_LOCAL_MODULE_ACTION=block (default): Blocks the commit if local module references are found.
#
# To set it, you can use:
#   export TF_LOCAL_MODULE_ACTION=warn
# or for a single command:
#   TF_LOCAL_MODULE_ACTION=block pre-commit run tf-local-module-check --all-files

set -e

# Paths relative to the git repository root to exclude from processing.
EXCLUDE_PATHS=("modules/")

# Default action is to warn
ACTION=${TF_LOCAL_MODULE_ACTION:-block}

# Flag to track if local modules are found
found_local_module=0

# Regex to find local module sources
# Looks for source = "./", source = "../"
# It handles spaces around '='.
regex='^\s*[^#\r\n]*source\s*=\s*"\.\.?/'

for file in "$@"; do
    for exclude_path in "${EXCLUDE_PATHS[@]}"; do
        if [[ "$file" == "$exclude_path"* ]]; then
            continue 2
        fi
    done

    if grep -q -E "$regex" "$file"; then
        echo "[WARNING] Found local Terraform module reference in $file" >&2
        grep -n -E "$regex" "$file" | sed 's/^/    /' >&2
        found_local_module=1
    fi
done

if [ "$found_local_module" -eq 1 ] && [ "$ACTION" = "block" ]; then
    echo "[ERROR] Commit blocked because local Terraform module references were found." >&2
    exit 1
fi

exit 0

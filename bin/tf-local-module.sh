#!/usr/bin/env bash

# This script checks for local Terraform module references (e.g., source = "../modules/foo").
#
# Control behavior with the TF_LOCAL_MODULE_ACTION environment variable:
# - TF_LOCAL_MODULE_ACTION=warn (default): Prints warnings but allows the commit.
# - TF_LOCAL_MODULE_ACTION=block: Blocks the commit if local module references are found.
#
# To set it, you can use:
#   export TF_LOCAL_MODULE_ACTION=block
# or for a single command:
#   TF_LOCAL_MODULE_ACTION=block pre-commit run terraform-local-module-check --all-files

# Default action is to warn
ACTION=${TF_LOCAL_MODULE_ACTION:-warn}

# Flag to track if local modules are found
found_local_module=0

# Regex to find local module sources
# Looks for source = "./", source = "../"
# It handles spaces around '='.
regex='source\s*=\s*"\.\.?/'

for file in "$@"; do
    if grep -q -E "$regex" "$file"; then
        echo "[WARNING] Found local Terraform module reference in $file" >&2
        grep -n -E "$regex" "$file" | sed 's/^/    /' >&2
        found_local_module=1
    fi
done

if [ "$found_local_module" -eq 1 ] && [ "$ACTION" = "block" ]; then
    echo "[ERROR] Commit blocked because local Terraform module references were found." >&2
    echo "Set TF_LOCAL_MODULE_ACTION=warn to allow committing with a warning." >&2
    exit 1
fi

exit 0

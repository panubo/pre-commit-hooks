#!/usr/bin/env bash
#
# This script scans Terraform files (.tf) to ensure that any outputs
# with potentially sensitive names are explicitly marked as 'sensitive = true'.
#
# It exits with status 0 if no issues are found.
# It exits with status 1 if 'hcledit' is not installed or if any sensitive
# outputs are found that are not properly marked.
#
# If files are passed to the script `./tf-check-sensitive-output.sh [FILE...]`
# then only those files are checked. If no files are passed in all *.tf files are checked.
#
# False positives can be ignored (a WARNING will be reported) by setting "sensitive = false"

# Bash strict mode
set -euo pipefail
IFS=$'\n\t'

# --- Main Script ---

main() {
  # Check for the 'hcledit' dependency.
  if ! command -v hcledit &>/dev/null; then
    echo "ERROR: hcledit is not installed. Please install it to run this script." >&2
    echo "Installation instructions: https://github.com/minamijoyo/hcledit" >&2
    echo "Homebrew install: \`brew install minamijoyo/hcledit/hcledit\`" >&2
    exit 1
  fi

  local error_found=0
  # Regex pattern for names that suggest sensitive content.
  # This is case-insensitive.
  local sensitive_pattern='pass|password|secret|key|private|token|cred|credential|conn_str'

  # --- Helper function to process a single file ---
  process_file() {
    local file=$1

    # When used with pre-commit, non-.tf files might be passed. Skip them.
    if ! [[ "$file" == *.tf ]]; then
      return
    fi

    # Get all output block addresses (e.g., "output.my_secret") from the current file.
    # The '|| true' prevents the script from exiting if grep finds no matches.
    local sensitive_outputs
    sensitive_outputs=$(hcledit block list -f "$file" | grep -E '^output\.' | grep -iE "$sensitive_pattern" || true)

    # If no sensitive outputs were found in this file, continue.
    if [[ -z "$sensitive_outputs" ]]; then
      return
    fi

    # For each potentially sensitive output, check if it's marked as sensitive.
    while IFS= read -r output_address; do
      # Get the value of the 'sensitive' attribute for the output block.
      local is_sensitive
      is_sensitive=$(hcledit attribute get "${output_address}.sensitive" -f "$file" 2>/dev/null || true)

      # Check the status of the 'sensitive' attribute and act accordingly.
      if [[ "$is_sensitive" == "true" ]]; then
        # Correct: The output is properly marked as sensitive.
        :
      elif [[ "$is_sensitive" == "false" ]]; then
        # Warn: The developer has explicitly marked this as not sensitive.
        echo "WARNING: Output '$output_address' in file '$file' is explicitly marked 'sensitive = false'. Please double-check this is intended." >&2
      else
        # Error: The 'sensitive' attribute is missing entirely.
        echo "ERROR: Output '$output_address' in file '$file' appears to be sensitive but is missing the 'sensitive = true' attribute. Set 'sensitive = false' to ignore." >&2
        error_found=1 # Modifies 'error_found' in the parent 'main' scope.
      fi
    done <<<"$sensitive_outputs"
  }

  # --- Execution Logic ---

  if [ "$#" -gt 0 ]; then
    # Case 1: Files are passed as arguments (pre-commit use case).
    echo "Scanning provided files..."
    for file in "$@"; do
      process_file "$file"
    done
  else
    # Case 2: No arguments. Find all '.tf' files to scan.
    echo "Scanning for sensitive outputs in all .tf files..."
    while IFS= read -r file; do
      process_file "$file"
    done < <(find . -type f -name "*.tf" -not -path "*.terraform*")
  fi

  # After checking all files, exit with the appropriate status code.
  if [[ "$error_found" -ne 0 ]]; then
    echo ""
    echo "Scan complete. Found sensitive outputs that are not correctly marked." >&2
    exit 1
  fi

  echo "Scan complete. No issues found."
  exit 0
}

# Execute the main function, passing all script arguments to it.
main "$@"

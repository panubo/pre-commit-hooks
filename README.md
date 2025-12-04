# Pre-Commit Hooks

This repo contains configs and plugins for the [pre-commit](https://pre-commit.com/)
framework.

- `bin` - the plugins / pre-commit hooks.

## Developing

Example:

`pre-commit try-repo ~/git/pre-commit-hooks tf-docs --verbose`

See https://pre-commit.com/index.html#developing-hooks-interactively

### tf-local-module-check

This hook checks for local Terraform module references (e.g. `source = "../"`).

To test it locally, you can run the script directly against a file containing a local module reference, like `tests/terraform/local_module.tf`.

**Test 'warn' behavior:**

Set the `TF_LOCAL_MODULE_ACTION` environment variable to `warn`.

```bash
$ TF_LOCAL_MODULE_ACTION=warn ./bin/tf-local-module.sh tests/terraform/local_module.tf
[WARNING] Found local Terraform module reference in tests/terraform/local_module.tf
    2:  source = "./module"
    6:  source = "../another/module"
```
The script will print a warning and exit with 0.

**Test default 'block' behavior:**

Set the `TF_LOCAL_MODULE_ACTION` environment variable to `block`.

```bash
$ TF_LOCAL_MODULE_ACTION=block ./bin/tf-local-module.sh tests/terraform/local_module.tf
[WARNING] Found local Terraform module reference in tests/terraform/local_module.tf
    2:  source = "./module"
    6:  source = "../another/module"
[ERROR] Commit blocked because local Terraform module references were found.
```
The script will print an error and exit with 1.

**Test with `pre-commit`:**

You can also use `pre-commit` to run the hook against a local repository.

```bash
$ pre-commit try-repo . tf-local-module-check --files tests/terraform/local_module.tf
```

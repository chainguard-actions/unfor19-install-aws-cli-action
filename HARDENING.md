<!-- markdownlint-disable -->

# Hardening Report: unfor19--install-aws-cli-action/1.0.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **unfor19--install-aws-cli-action/1.0.8** was hardened automatically. 10 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `set-env-vars` step in action.yml directly interpolates `${{ inputs.* }}` expressions inside a `run:` shell command string. All eight inputs (version, arch, verbose, lightsailctl, bindir, installrootdir, rootdir, workdir) are substituted by the GitHub Actions template engine before the shell ever sees them, allowing an attacker to inject arbitrary shell metacharacters (`;`, `|`, `$(...)`, etc.) via any of these inputs. Example offending lines:
  `echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV`
  `echo "BINDIR=${{ inputs.bindir }}" >> $GITHUB_ENV`
All values should be passed via `env:` variables and then referenced as quoted shell variables (e.g., `"$INPUT_VERSION"`) instead of being interpolated directly.

Locations:

- `action.yml:46`
- `action.yml:47`
- `action.yml:48`
- `action.yml:49`
- `action.yml:50`
- `action.yml:51`
- `action.yml:52`
- `action.yml:53`

### github-env-injection (severity: high)

The `set-env-vars` step writes all eight `${{ inputs.* }}` values directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). If any input value contains a newline character, an attacker can inject arbitrary additional environment variable definitions into the runner's environment (e.g., setting `ACTIONS_RUNTIME_TOKEN` or other sensitive variables). Affected writes:
  `echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV`
  `echo "AWS_CLI_ARCH=${{ inputs.arch }}" >> $GITHUB_ENV`
  `echo "VERBOSE=${{ inputs.verbose }}" >> $GITHUB_ENV`
  `echo "LIGHTSAILCTL=${{ inputs.lightsailctl }}" >> $GITHUB_ENV`
  `echo "BINDIR=${{ inputs.bindir }}" >> $GITHUB_ENV`
  `echo "INSTALLROOTDIR=${{ inputs.installrootdir }}" >> $GITHUB_ENV`
  `echo "ROOTDIR=${{ inputs.rootdir }}" >> $GITHUB_ENV`
  `echo "WORKDIR=${{ inputs.workdir }}" >> $GITHUB_ENV`
Each value must be sanitized before writing, e.g.: `safe=$(printf '%s' "$INPUT_VERSION" | tr -d '\n\r'); echo "AWS_CLI_VERSION=$safe" >> $GITHUB_ENV`

Locations:

- `action.yml:46`
- `action.yml:47`
- `action.yml:48`
- `action.yml:49`
- `action.yml:50`
- `action.yml:51`
- `action.yml:52`
- `action.yml:53`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:49`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.arch }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:50`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.verbose }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:51`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.lightsailctl }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:52`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.bindir }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:53`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.installrootdir }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:54`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.rootdir }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:55`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.workdir }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:56`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed the set-env-vars step in action.yml by: (1) Moving all eight ${{ inputs.* }} expressions (version, arch, verbose, lightsailctl, bindir, installrootdir, rootdir, workdir) from the run: shell block into a new env: block as INPUT_* variables. (2) In the run: block, each value is now sanitized with `safe_X=$(printf '%s' "$INPUT_X" | tr -d '\n\r')` before being written to $GITHUB_ENV, preventing both shell injection and newline-based GITHUB_ENV injection attacks.


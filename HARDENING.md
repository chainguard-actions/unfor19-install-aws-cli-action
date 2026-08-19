<!-- markdownlint-disable -->

# Hardening Report: unfor19--install-aws-cli-action/v1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **unfor19--install-aws-cli-action/v1** was hardened automatically. 10 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): The `set-env-vars` step in action.yml directly interpolates `${{ inputs.* }}` expressions inside `run:` shell command strings. All eight inputs (version, arch, verbose, lightsailctl, bindir, installrootdir, rootdir, workdir) are expanded by the GitHub Actions template engine before the shell sees the command, allowing an attacker-controlled input value containing shell metacharacters (`;`, `|`, `$(...)`, etc.) to execute arbitrary commands. Example offending lines:
  `echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV`
  `echo "AWS_CLI_ARCH=${{ inputs.arch }}" >> $GITHUB_ENV`
  (and 6 more similar lines)
Fix: move each input into an `env:` block and reference the env var (double-quoted) inside the `run:` script.

Locations:

- `action.yml:44`
- `action.yml:45`
- `action.yml:46`
- `action.yml:47`
- `action.yml:48`
- `action.yml:49`
- `action.yml:50`
- `action.yml:51`

### github-env-injection (severity: high)

The `set-env-vars` step writes all eight `${{ inputs.* }}` values directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). A newline character embedded in any input value (e.g. `inputs.version`, `inputs.bindir`, etc.) would inject additional key=value pairs into the runner's environment, potentially overwriting security-sensitive variables such as `PATH` or `LD_PRELOAD`. Offending lines include:
  `echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV`
  `echo "BINDIR=${{ inputs.bindir }}" >> $GITHUB_ENV`
  (and 6 more similar lines)
Fix: sanitize each value with `safe=$(printf '%s' "$INPUT_VAR" | tr -d '\n\r')` before writing to `$GITHUB_ENV`.

Locations:

- `action.yml:44`
- `action.yml:45`
- `action.yml:46`
- `action.yml:47`
- `action.yml:48`
- `action.yml:49`
- `action.yml:50`
- `action.yml:51`

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

Fixed the set-env-vars step in hardened/action/action.yml by: (1) Moving all eight ${{ inputs.* }} expressions (version, arch, verbose, lightsailctl, bindir, installrootdir, rootdir, workdir) out of the run: block and into a step-level env: block as INPUT_* variables. (2) Sanitizing each env var value with `printf '%s' "$INPUT_VAR" | tr -d '\n\r'` before writing to $GITHUB_ENV, preventing newline injection attacks. The run: script now only references plain environment variables (no template expressions), and all values are stripped of newlines/carriage-returns before being written to the runner environment.

### Iteration 2

**Fixes applied:** unpinned-uses, missing-permissions, script-injection

**Notes:**

Fixed all three findings in .github/workflows/test.yaml: (1) Pinned all 6 action references to full SHA digests with mutable ref preserved in comments; (2) Added top-level `permissions: {}` to restrict default token permissions; (3) Fixed script injection in test_arm and test_arm64 jobs by moving `${{ matrix.AWS_CLI_VERSION }}` and `${{ steps.prep.outputs.tagged_image }}` expressions out of run: shell strings and into step-level env: blocks, referencing them as plain environment variables in the shell scripts.

### Iteration 3

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed both findings in the 'Prepare' steps of test_arm and test_arm64 jobs in .github/workflows/test.yaml:

1. script-injection: Quoted all expansions of ${AWS_CLI_VERSION} and first sanitized it into SAFE_VERSION via `printf '%s' "${AWS_CLI_VERSION}" | tr -d '\n\r'` to prevent shell metacharacter interpretation.

2. github-env-injection: Added sanitization of the full tagged_image value before writing to $GITHUB_OUTPUT: `safe_tag=$(printf '%s' "${IMAGE}:${TAG}" | tr -d '\n\r')` then `echo "tagged_image=${safe_tag}" >> "${GITHUB_OUTPUT}"`. This prevents newline-based injection of arbitrary key=value pairs into the output file.

Both fixes were applied to both occurrences (test_arm and test_arm64 jobs).


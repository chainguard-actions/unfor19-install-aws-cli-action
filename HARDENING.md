<!-- markdownlint-disable -->

# Hardening Report: unfor19--install-aws-cli-action/v1.0.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **unfor19--install-aws-cli-action/v1.0.4** was hardened automatically. 9 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): The `set-env-vars` step directly interpolates six `inputs.*` expressions inside a `run:` shell command string. Before the shell executes the command, GitHub Actions substitutes the raw user-supplied values into the script text, enabling command injection. Offending lines:
  - `echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV`
  - `echo "AWS_CLI_ARCH=${{ inputs.arch }}" >> $GITHUB_ENV`
  - `echo "VERBOSE=${{ inputs.verbose }}" >> $GITHUB_ENV`
  - `echo "LIGHTSAILCTL=${{ inputs.lightsailctl }}" >> $GITHUB_ENV`
  - `echo "ROOTDIR=${{ inputs.rootdir }}" >> $GITHUB_ENV`
  - `echo "WORKDIR=${{ inputs.workdir }}" >> $GITHUB_ENV`
Fix: move each input into an `env:` block and reference the env var (double-quoted) inside the `run:` script instead.

Locations:

- `action.yml:39`
- `action.yml:40`
- `action.yml:41`
- `action.yml:42`
- `action.yml:43`
- `action.yml:44`

### script-injection (severity: high)

Rule (a): The `install-aws-cli` step directly interpolates `${{ github.action_path }}` inside a `run:` shell command string: `sudo --preserve-env ${{ github.action_path }}/entrypoint.sh`. Any `${{ ... }}` expression interpolated directly into a `run:` block is a script-injection risk because the value is substituted into the shell script text before the shell parses it. Fix: use the `$GITHUB_ACTION_PATH` environment variable instead (e.g. `sudo --preserve-env "$GITHUB_ACTION_PATH/entrypoint.sh"`).

Locations:

- `action.yml:47`

### github-env-injection (severity: high)

The `set-env-vars` step writes all six `inputs.*` values directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). Because the values are interpolated directly from `${{ inputs.* }}` expressions, an attacker can supply a value containing newline characters to inject arbitrary key=value pairs into the runner's environment for subsequent steps. Offending writes:
  - `echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV` (line 39)
  - `echo "AWS_CLI_ARCH=${{ inputs.arch }}" >> $GITHUB_ENV` (line 40)
  - `echo "VERBOSE=${{ inputs.verbose }}" >> $GITHUB_ENV` (line 41)
  - `echo "LIGHTSAILCTL=${{ inputs.lightsailctl }}" >> $GITHUB_ENV` (line 42)
  - `echo "ROOTDIR=${{ inputs.rootdir }}" >> $GITHUB_ENV` (line 43)
  - `echo "WORKDIR=${{ inputs.workdir }}" >> $GITHUB_ENV` (line 44)
Fix: sanitize each value before writing, e.g. `safe=$(printf '%s' "$INPUT_VERSION" | tr -d '\n\r'); echo "AWS_CLI_VERSION=$safe" >> "$GITHUB_ENV"`.

Locations:

- `action.yml:39`
- `action.yml:40`
- `action.yml:41`
- `action.yml:42`
- `action.yml:43`
- `action.yml:44`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.version }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:41`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.arch }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:42`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.verbose }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:43`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.lightsailctl }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:44`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.rootdir }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:45`

### static-inline-injection (severity: high)

shell injection: expression "${{ inputs.workdir }}" appears directly in run: block of step ""; move to env: map

Locations:

- `action.yml:46`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection

**Notes:**

Fixed hardened/action/action.yml:
1. set-env-vars step: moved all six inputs.* expressions (version, arch, verbose, lightsailctl, rootdir, workdir) into an env: block as INPUT_* variables. Each value is sanitized with `printf '%s' "$VAR" | tr -d '\n\r'` before being written to $GITHUB_ENV, preventing both script injection and newline-based GITHUB_ENV injection.
2. install-aws-cli step: replaced `${{ github.action_path }}` with the built-in `$GITHUB_ACTION_PATH` environment variable (double-quoted), eliminating the expression interpolation from the run block.

### Iteration 2

**Fixes applied:** unpinned-uses, missing-permissions, script-injection

**Notes:**

Fixed all three findings in .github/workflows/test.yaml:

1. unpinned-uses: Pinned all 6 unique action references to full 40-char SHAs with tag comments preserved: actions/checkout@v2→ee0669bd, unfor19/hero-action@master→f2d40090, docker/setup-qemu-action@v1→27d0a4f1, docker/setup-buildx-action@master→5b9cf390, actions/cache@v2→84922603, docker/build-push-action@v2→ac9327ea.

2. missing-permissions: Added top-level `permissions: {}` and per-job `permissions: contents: read` for all four jobs (dispatch_test_action, test_dirs, test_amd64, test_arm64).

3. script-injection: In test_arm64 'Prepare' step, moved `${{ matrix.AWS_CLI_VERSION }}` into an env: block and referenced as `${AWS_CLI_VERSION}` in the shell. In 'Test In Docker' step, moved `${{ steps.prep.outputs.tagged_image }}` into an env: block as TAGGED_IMAGE and referenced as `"$TAGGED_IMAGE"` in the shell.


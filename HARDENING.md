<!-- markdownlint-disable -->

# Hardening Report: unfor19--install-aws-cli-action/v1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **unfor19--install-aws-cli-action/v1** was hardened automatically. 10 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Eight `${{ inputs.* }}` expressions are interpolated directly inside the `run:` shell command string in the `set-env-vars` step. GitHub Actions performs YAML template substitution before the shell executes the command, so attacker-controlled input values (e.g. containing `;`, `|`, `$(...)`, or newlines) are injected verbatim into the shell. Offending lines:
  - `echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV`
  - `echo "AWS_CLI_ARCH=${{ inputs.arch }}" >> $GITHUB_ENV`
  - `echo "VERBOSE=${{ inputs.verbose }}" >> $GITHUB_ENV`
  - `echo "LIGHTSAILCTL=${{ inputs.lightsailctl }}" >> $GITHUB_ENV`
  - `echo "BINDIR=${{ inputs.bindir }}" >> $GITHUB_ENV`
  - `echo "INSTALLROOTDIR=${{ inputs.installrootdir }}" >> $GITHUB_ENV`
  - `echo "ROOTDIR=${{ inputs.rootdir }}" >> $GITHUB_ENV`
  - `echo "WORKDIR=${{ inputs.workdir }}" >> $GITHUB_ENV`
Fix: move each input into an `env:` block and reference the env var (double-quoted) inside the `run:` script instead of using `${{ ... }}` directly.

Locations:

- `action.yml:45`
- `action.yml:46`
- `action.yml:47`
- `action.yml:48`
- `action.yml:49`
- `action.yml:50`
- `action.yml:51`
- `action.yml:52`

### github-env-injection (severity: high)

The `set-env-vars` step writes all eight `${{ inputs.* }}` values directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). An input value containing a newline character can inject additional key=value pairs into the runner's environment, potentially overwriting security-sensitive variables consumed by later steps. All eight echo lines are affected:
  - `echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV` (line 45)
  - `echo "AWS_CLI_ARCH=${{ inputs.arch }}" >> $GITHUB_ENV` (line 46)
  - `echo "VERBOSE=${{ inputs.verbose }}" >> $GITHUB_ENV` (line 47)
  - `echo "LIGHTSAILCTL=${{ inputs.lightsailctl }}" >> $GITHUB_ENV` (line 48)
  - `echo "BINDIR=${{ inputs.bindir }}" >> $GITHUB_ENV` (line 49)
  - `echo "INSTALLROOTDIR=${{ inputs.installrootdir }}" >> $GITHUB_ENV` (line 50)
  - `echo "ROOTDIR=${{ inputs.rootdir }}" >> $GITHUB_ENV` (line 51)
  - `echo "WORKDIR=${{ inputs.workdir }}" >> $GITHUB_ENV` (line 52)
Fix: use `safe=$(printf '%s' "$INPUT_VAR" | tr -d '\n\r')` before each write, or use the `env:` block to pass inputs and sanitize before appending to GITHUB_ENV.

Locations:

- `action.yml:45`
- `action.yml:46`
- `action.yml:47`
- `action.yml:48`
- `action.yml:49`
- `action.yml:50`
- `action.yml:51`
- `action.yml:52`

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

Fixed the set-env-vars step in action.yml by: (1) moving all 8 ${{ inputs.* }} expressions from the run: shell string into an env: block (INPUT_VERSION, INPUT_ARCH, INPUT_VERBOSE, INPUT_LIGHTSAILCTL, INPUT_BINDIR, INPUT_INSTALLROOTDIR, INPUT_ROOTDIR, INPUT_WORKDIR); (2) sanitizing each value with `printf '%s' "$VAR" | tr -d '\n\r'` before writing to $GITHUB_ENV to prevent newline injection. This resolves all script-injection, github-env-injection, and static-inline-injection findings.


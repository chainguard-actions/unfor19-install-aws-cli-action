<!-- markdownlint-disable -->

# Hardening Report: unfor19--install-aws-cli-action/v1.0.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **unfor19--install-aws-cli-action/v1.0.6** was hardened automatically. 8 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Sub-rule (a): Multiple `${{ inputs.* }}` expressions are directly interpolated inside `run:` shell commands in the `set-env-vars` step. An attacker-controlled input value containing shell metacharacters (`;`, `|`, `&`, `$(...)`, backticks, etc.) will be parsed by the shell before any quoting takes effect, enabling command injection. Offending lines:
- `echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV`
- `echo "AWS_CLI_ARCH=${{ inputs.arch }}" >> $GITHUB_ENV`
- `echo "VERBOSE=${{ inputs.verbose }}" >> $GITHUB_ENV`
- `echo "LIGHTSAILCTL=${{ inputs.lightsailctl }}" >> $GITHUB_ENV`
- `echo "ROOTDIR=${{ inputs.rootdir }}" >> $GITHUB_ENV`
- `echo "WORKDIR=${{ inputs.workdir }}" >> $GITHUB_ENV`

Sub-rule (a): `${{ github.action_path }}` is also directly interpolated in the `install-aws-cli` step's `run:` command: `sudo --preserve-env ${{ github.action_path }}/entrypoint.sh`. All `${{ ... }}` expressions inside `run:` blocks must be moved to `env:` variables and then referenced as quoted shell variables.

Locations:

- `action.yml:40`
- `action.yml:41`
- `action.yml:42`
- `action.yml:43`
- `action.yml:44`
- `action.yml:45`
- `action.yml:49`

### github-env-injection (severity: high)

The `set-env-vars` step writes all six `inputs.*` values directly to `$GITHUB_ENV` without the required sanitization step (`printf '%s' "$VAR" | tr -d '\n\r'`). Because `${{ inputs.version }}`, `${{ inputs.arch }}`, `${{ inputs.verbose }}`, `${{ inputs.lightsailctl }}`, `${{ inputs.rootdir }}`, and `${{ inputs.workdir }}` are interpolated directly into the shell command string, a newline character embedded in any of these values would allow an attacker to inject arbitrary additional `KEY=VALUE` pairs into `$GITHUB_ENV`, potentially overwriting sensitive environment variables used by subsequent steps. Each write must be preceded by sanitization, e.g.:
```
safe=$(printf '%s' "$INPUT_VERSION" | tr -d '\n\r')
echo "AWS_CLI_VERSION=$safe" >> "$GITHUB_ENV"
```

Locations:

- `action.yml:40`
- `action.yml:41`
- `action.yml:42`
- `action.yml:43`
- `action.yml:44`
- `action.yml:45`

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

Fixed action.yml by: (1) Moving all six ${{ inputs.* }} expressions (version, arch, verbose, lightsailctl, rootdir, workdir) from the run: block of set-env-vars step into an env: block, then sanitizing each with `printf '%s' "$VAR" | tr -d '\n\r'` before writing to $GITHUB_ENV to prevent both shell injection and newline-based GITHUB_ENV injection. (2) Moving ${{ github.action_path }} from the run: block of install-aws-cli step into an env: block (ACTION_PATH) and referencing it as a quoted shell variable "$ACTION_PATH/entrypoint.sh".


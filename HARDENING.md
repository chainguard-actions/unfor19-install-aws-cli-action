<!-- markdownlint-disable -->

# Hardening Report: unfor19--install-aws-cli-action/v1.0.4

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `1`

Action **unfor19--install-aws-cli-action/v1.0.4** was hardened automatically. 8 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### github-env-injection (severity: high)

The 'set-env-vars' step in action.yml writes multiple unsanitized inputs directly to $GITHUB_ENV without the required sanitization step (`printf '%s' ... | tr -d '\n\r'`). Specifically, `${{ inputs.version }}`, `${{ inputs.arch }}`, `${{ inputs.verbose }}`, `${{ inputs.lightsailctl }}`, `${{ inputs.rootdir }}`, and `${{ inputs.workdir }}` are interpolated directly into echo commands that append to $GITHUB_ENV. An attacker can supply a value containing newline characters to inject arbitrary environment variables into subsequent steps.

Locations:

- `action.yml:37`
- `action.yml:38`
- `action.yml:39`
- `action.yml:40`
- `action.yml:41`
- `action.yml:42`

### script-injection (severity: high)

Sub-rule (a): GitHub Actions expressions are interpolated directly inside run: shell command strings in two steps.

1. The 'set-env-vars' step interpolates `${{ inputs.version }}`, `${{ inputs.arch }}`, `${{ inputs.verbose }}`, `${{ inputs.lightsailctl }}`, `${{ inputs.rootdir }}`, and `${{ inputs.workdir }}` directly in shell echo commands. These are attacker-controlled inputs that flow through YAML template substitution before the shell sees them, enabling command injection.

2. The 'install-aws-cli' step uses `${{ github.action_path }}` directly in: `sudo --preserve-env ${{ github.action_path }}/entrypoint.sh`. Any `${{ ... }}` expression interpolated directly into a run: block is a script-injection finding regardless of context.

Locations:

- `action.yml:37`
- `action.yml:38`
- `action.yml:39`
- `action.yml:40`
- `action.yml:41`
- `action.yml:42`
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

**Fixes applied:** github-env-injection, script-injection, static-inline-injection

**Notes:**

Fixed all findings in action.yml:
1. Moved all ${{ inputs.* }} expressions (version, arch, verbose, lightsailctl, rootdir, workdir) from inline run: shell strings into an env: block for the set-env-vars step.
2. Added sanitization for each input using `printf '%s' "$VAR" | tr -d '\n\r'` before writing to $GITHUB_ENV, preventing newline injection.
3. Moved ${{ github.action_path }} from the inline run: string into an env: block (ACTION_PATH) for the install-aws-cli step, and quoted the variable reference properly.
4. Quoted $GITHUB_ENV references with double quotes for good measure.


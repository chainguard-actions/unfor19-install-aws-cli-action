<!-- markdownlint-disable -->

# Hardening Report: unfor19--install-aws-cli-action/v1.0.6

> This file was generated automatically by the hardening agent.

**Policy SHA:** `d636be7e43ef829af6e853da6b3c7566db9f72fe`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **unfor19--install-aws-cli-action/v1.0.6** was hardened automatically. 9 finding(s) were identified and resolved across 3 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a) violation: Multiple ${{ inputs.* }} expressions are directly interpolated inside run: shell command strings in the set-env-vars step. Offending lines include: echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV, echo "AWS_CLI_ARCH=${{ inputs.arch }}" >> $GITHUB_ENV, echo "VERBOSE=${{ inputs.verbose }}" >> $GITHUB_ENV, echo "LIGHTSAILCTL=${{ inputs.lightsailctl }}" >> $GITHUB_ENV, echo "ROOTDIR=${{ inputs.rootdir }}" >> $GITHUB_ENV, echo "WORKDIR=${{ inputs.workdir }}" >> $GITHUB_ENV. Any of these inputs could contain shell metacharacters (;, |, &, $(...), backticks) that are parsed by the shell before the value is written to GITHUB_ENV, enabling command injection.

Locations:

- `action.yml:36`

### script-injection (severity: high)

Rule (a) violation: ${{ github.action_path }} is directly interpolated inside a run: shell command string in the install-aws-cli step: run: sudo --preserve-env ${{ github.action_path }}/entrypoint.sh. Any ${{ ... }} expression directly inside a run: block is a script-injection finding per the check rules, as YAML template substitution occurs before the shell ever sees the value.

Locations:

- `action.yml:43`

### github-env-injection (severity: high)

The set-env-vars step writes user-controlled inputs.* values directly to $GITHUB_ENV without the required sanitization step (printf '%s' ... | tr -d '\n\r'). An attacker-controlled input containing a newline character can inject arbitrary environment variable definitions into the runner environment for subsequent steps. All six writes are affected: echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV, echo "AWS_CLI_ARCH=${{ inputs.arch }}" >> $GITHUB_ENV, echo "VERBOSE=${{ inputs.verbose }}" >> $GITHUB_ENV, echo "LIGHTSAILCTL=${{ inputs.lightsailctl }}" >> $GITHUB_ENV, echo "ROOTDIR=${{ inputs.rootdir }}" >> $GITHUB_ENV, echo "WORKDIR=${{ inputs.workdir }}" >> $GITHUB_ENV.

Locations:

- `action.yml:36`

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

Fixed all findings in action.yml:
1. set-env-vars step: Moved all 6 ${{ inputs.* }} expressions to the step's env: block (INPUT_VERSION, INPUT_ARCH, INPUT_VERBOSE, INPUT_LIGHTSAILCTL, INPUT_ROOTDIR, INPUT_WORKDIR). Each value is sanitized with `printf '%s' "$VAR" | tr -d '\n\r'` before being written to $GITHUB_ENV, preventing both script-injection and github-env-injection attacks.
2. install-aws-cli step: Moved ${{ github.action_path }} to the step's env: block as ACTION_PATH, and updated the run: command to use "$ACTION_PATH/entrypoint.sh" (properly quoted).
3. Also quoted $GITHUB_OUTPUT reference for consistency.

### Iteration 2

**Fixes applied:** unpinned-uses, script-injection, missing-permissions

**Notes:**

Fixed all three findings in hardened/action/.github/workflows/test.yaml:
1. unpinned-uses: Pinned all 6 action references to full 40-char commit SHAs (actions/checkout@v3→f43a0e5, unfor19/hero-action@master→f2d4009, docker/setup-qemu-action@v1→27d0a4f, docker/setup-buildx-action@master→5b9cf39, actions/cache@v2→8492260, docker/build-push-action@v2→ac9327e), preserving original tags in comments.
2. script-injection: Moved ${{ matrix.AWS_CLI_VERSION }} in the 'Prepare' step into an env: block (AWS_CLI_VERSION) and referenced it as ${AWS_CLI_VERSION} in shell. Moved ${{ steps.prep.outputs.tagged_image }} in the 'Test In Docker' step into an env: block (TAGGED_IMAGE) and referenced it as "$TAGGED_IMAGE" in shell.
3. missing-permissions: Added top-level `permissions: {}` block to deny all default token permissions.

### Iteration 3

**Fixes applied:** script-injection, github-env-injection

**Notes:**

Fixed both findings in the 'Prepare' step of the test_arm64 job in .github/workflows/test.yaml:
1. script-injection: Added double quotes around `${AWS_CLI_VERSION}` in the TAG assignment to prevent shell metacharacter injection.
2. github-env-injection: Added sanitization using `printf '%s' ... | tr -d '\n\r'` before writing the tagged_image value to $GITHUB_OUTPUT to prevent newline injection attacks.


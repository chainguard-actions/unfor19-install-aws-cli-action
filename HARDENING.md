<!-- markdownlint-disable -->

# Hardening Report: unfor19--install-aws-cli-action/v1

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **unfor19--install-aws-cli-action/v1** was hardened automatically. 11 finding(s) were identified and resolved across 2 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the set-env-vars step puts GitHub expressions straight into the run: script. Examples: `echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV`, plus the same pattern for inputs.arch, inputs.verbose, inputs.lightsailctl, inputs.bindir, inputs.installrootdir, inputs.rootdir and inputs.workdir. Actions substitutes the input text into the script before bash runs it, so an input containing `"`, `$(...)` or backticks runs as shell commands. Fix: pass each input through the step's env: block and use it double-quoted.

Locations:

- `action.yml:47`

### github-env-injection (severity: high)

The set-env-vars step writes caller-supplied inputs (inputs.version, arch, verbose, lightsailctl, bindir, installrootdir, rootdir, workdir) to $GITHUB_ENV with no `printf '%s' ... | tr -d '\n\r'` step first. A value containing a newline can add any environment variable (for example PATH, LD_PRELOAD or BASH_ENV) for every later step in the job. The next step runs entrypoint.sh as root via `sudo --preserve-env`, which carries those variables into the root process. Example: `echo "BINDIR=${{ inputs.bindir }}" >> $GITHUB_ENV`.

Locations:

- `action.yml:47`

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

### prior-fix (severity: high)

Carried forward from this version's previous harden, which fixed it; fix it again unless the code no longer has the problem. The previous harden changed action.yml without recording a finding for it, and this analysis reported nothing there. Re-apply its security changes unless the code no longer needs them. The previous patch:
```diff
diff --git a/action.yml b/action.yml
index 9b7296e..43e9bf3 100644
--- a/action.yml
+++ b/action.yml
@@ -40,20 +40,53 @@ outputs:
   version:
     description: "The AWS CLI version that was installed"
     value: ${{ steps.set-output.outputs.version }}
-
 runs:
   using: "composite"
   steps:
     - id: set-env-vars
+      env:
+        INPUT_VERSION: ${{ inputs.version }}
+        INPUT_ARCH: ${{ inputs.arch }}
+        INPUT_VERBOSE: ${{ inputs.verbose }}
+        INPUT_LIGHTSAILCTL: ${{ inputs.lightsailctl }}
+        INPUT_BINDIR: ${{ inputs.bindir }}
+        INPUT_INSTALLROOTDIR: ${{ inputs.installrootdir }}
+        INPUT_ROOTDIR: ${{ inputs.rootdir }}
+        INPUT_WORKDIR: ${{ inputs.workdir }}
       run: |
-        echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV
-        echo "AWS_CLI_ARCH=${{ inputs.arch }}" >> $GITHUB_ENV        
-        echo "VERBOSE=${{ inputs.verbose }}" >> $GITHUB_ENV
-        echo "LIGHTSAILCTL=${{ inputs.lightsailctl }}" >> $GITHUB_ENV
-        echo "BINDIR=${{ inputs.bindir }}" >> $GITHUB_ENV
-        echo "INSTALLROOTDIR=${{ inputs.installrootdir }}" >> $GITHUB_ENV
-        echo "ROOTDIR=${{ inputs.rootdir }}" >> $GITHUB_ENV
-        echo "WORKDIR=${{ inputs.workdir }}" >> $GITHUB_ENV
+        safe_version=$(printf '%s' "$INPUT_VERSION" | tr -d '\n\r')
+        safe_arch=$(printf '%s' "$INPUT_ARCH" | tr -d '\n\r')
+        safe_verbose=$(printf '%s' "$INPUT_VERBOSE" | tr -d '\n\r')
+        safe_lightsailctl=$(printf '%s' "$INPUT_LIGHTSAILCTL" | tr -d '\n\r')
+        safe_bindir=$(printf '%s' "$INPUT_BINDIR" | tr -d '\n\r')
+        safe_installrootdir=$(printf '%s' "$INPUT_INSTALLROOTDIR" | tr -d '\n\r')
+        safe_rootdir=$(printf '%s' "$INPUT_ROOTDIR" | tr -d '\n\r')
+        safe_workdir=$(printf '%s' "$INPUT_WORKDIR" | tr -d '\n\r')
+        echo "AWS_CLI_VERSION=$safe_version" >> "$GITHUB_ENV"
+        echo "AWS_CLI_ARCH=$safe_arch" >> "$GITHUB_ENV"
+        echo "VERBOSE=$safe_verbose" >> "$GITHUB_ENV"
+        echo "LIGHTSAILCTL=$safe_lightsailctl" >> "$GITHUB_ENV"
+        echo "BINDIR=$safe_bindir" >> "$GITHUB_ENV"
+        echo "INSTALLROOTDIR=$safe_installrootdir" >> "$GITHUB_ENV"
+        echo "ROOTDIR=$safe_rootdir" >> "$GITHUB_ENV"
+        echo "WORKDIR=$safe_workdir" >> "$GITHUB_ENV"
       shell: bash
     - id: install-aws-cli
       run: sudo --preserve-env ${GITHUB_ACTION_PATH}/entrypoint.sh

```

Locations:

- `action.yml`

## Iteration Notes

### Iteration 1

**Fixes applied:** script-injection, github-env-injection, static-inline-injection, prior-fix

**Notes:**

I changed the set-env-vars step in action.yml. All 8 inputs (version, arch, verbose, lightsailctl, bindir, installrootdir, rootdir, workdir) now come in through the step's env: block instead of being written into the script. Newlines and carriage returns are removed from each value before it is written to $GITHUB_ENV, and "$GITHUB_ENV" is now quoted. This puts back the previous harden's patch. I also made one change no finding asked for: the set-output step now strips newlines from the `aws --version` output before writing it to $GITHUB_OUTPUT. It uses `|| true` so a failing `aws --version` still doesn't stop the step, as before. I haven't run the action or its tests after these edits.

### Iteration 2

**Fixes applied:** script-injection

**Notes:**

Added double quotes around ${GITHUB_ACTION_PATH}/entrypoint.sh in the install-aws-cli step of action.yml, so the path cannot be split on spaces or glob-expanded.


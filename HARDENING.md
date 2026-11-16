<!-- markdownlint-disable -->

# Hardening Report: unfor19--install-aws-cli-action/1.0.8

> This file was generated automatically by the hardening agent.

**Policy SHA:** `374911c4be584df24e6da57af2d990570ef0f859`

**Test Policy SHA:** `843adf9e4b8f85d0c08b27b9d0b09dd094b54702`

**Harden Agent Version:** `2`

Action **unfor19--install-aws-cli-action/1.0.8** was hardened automatically. 12 finding(s) were identified and resolved across 1 iteration(s).

## Findings Fixed

### script-injection (severity: high)

Rule (a): the 'set-env-vars' step puts ${{ inputs.* }} expressions straight into a run: script, for example `echo "AWS_CLI_VERSION=${{ inputs.version }}" >> $GITHUB_ENV`. The same pattern is used for inputs.arch, verbose, lightsailctl, bindir, installrootdir, rootdir and workdir. GitHub substitutes these values into the script before the shell parses it, so a value containing shell metacharacters runs as commands. Fix: pass each input through the step's env: block and expand it double-quoted.

Locations:

- `action.yml:48`

### github-env-injection (severity: high)

The 'set-env-vars' step writes every input (version, arch, verbose, lightsailctl, bindir, installrootdir, rootdir, workdir) to $GITHUB_ENV with `echo "NAME=${{ inputs.X }}" >> $GITHUB_ENV`. Nothing strips newlines first. An input with a newline in it can set any environment variable for later steps (for example LD_PRELOAD, BASH_ENV or PATH), and the next step runs entrypoint.sh with `sudo --preserve-env`. Fix: run each value through `printf '%s' "$VAR" | tr -d '\n\r'` before writing it.

Locations:

- `action.yml:48`

### github-env-injection (severity: high)

The 'set-output' step runs `echo "version=$(aws --version)" >> $GITHUB_OUTPUT` without stripping newlines. The output comes from whichever `aws` binary is first on PATH, and the install location is set by untrusted inputs (bindir/installrootdir), so the value is not a literal computed in this step. Fix: sanitize it first, e.g. `v=$(aws --version | tr -d '\n\r'); echo "version=$v" >> "$GITHUB_OUTPUT"`.

Locations:

- `action.yml:61`

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
index 9b7296e..2e03ec2 100644
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
+        echo "AWS_CLI_VERSION=$safe_version" >> "$GITHUB_ENV"
+        safe_arch=$(printf '%s' "$INPUT_ARCH" | tr -d '\n\r')
+        echo "AWS_CLI_ARCH=$safe_arch" >> "$GITHUB_ENV"
+        safe_verbose=$(printf '%s' "$INPUT_VERBOSE" | tr -d '\n\r')
+        echo "VERBOSE=$safe_verbose" >> "$GITHUB_ENV"
+        safe_lightsailctl=$(printf '%s' "$INPUT_LIGHTSAILCTL" | tr -d '\n\r')
+        echo "LIGHTSAILCTL=$safe_lightsailctl" >> "$GITHUB_ENV"
+        safe_bindir=$(printf '%s' "$INPUT_BINDIR" | tr -d '\n\r')
+        echo "BINDIR=$safe_bindir" >> "$GITHUB_ENV"
+        safe_installrootdir=$(printf '%s' "$INPUT_INSTALLROOTDIR" | tr -d '\n\r')
+        echo "INSTALLROOTDIR=$safe_installrootdir" >> "$GITHUB_ENV"
+        safe_rootdir=$(printf '%s' "$INPUT_ROOTDIR" | tr -d '\n\r')
+        echo "ROOTDIR=$safe_rootdir" >> "$GITHUB_ENV"
+        safe_workdir=$(printf '%s' "$INPUT_WORKDIR" | tr -d '\n\r')
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

action.yml: every ${{ inputs.* }} in the set-env-vars step now goes through the step's env: block. Each value has newlines stripped (printf | tr -d '\n\r') before it is written to the quoted "$GITHUB_ENV". This re-applies the previous harden's patch. In set-output, the `aws --version` result is captured first, with `|| true` so a failing command still doesn't stop the step (upstream ran it inside echo, which hid its exit status). Newlines are then stripped before it goes to "$GITHUB_OUTPUT". I also quoted the entrypoint path. I haven't run the action to test these changes.


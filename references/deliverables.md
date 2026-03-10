# Deliverables Format

## test.patch

Unified diff format. Must include test.sh and test files.

**Requirements:**
- NO comments in any file
- Tests must fail without solution, pass with solution
- Tests must work offline (no network access)
- Non-redundant tests only
- Match repository's existing test style and conventional method names
- Add enough relevant tests to cover the problem fully (aim for 100% problem coverage; avoid trivial single-case tests)
- Ensure test.sh is included at repo root with file mode 100755
- Generate using `git diff --cached`

**test.sh Structure (Required):**
```bash
#!/bin/bash
set -e

case "$1" in
  base)
    # Run existing tests - should pass at base commit
    [test command for existing tests]
    ;;
  new)
    # Run only new tests - should fail before solution
    [test command for new tests only]
    ;;
  *)
    echo "Usage: ./test.sh {base|new}"
    exit 1
    ;;
esac
```

**test.sh Rules:**
- `./test.sh base` runs existing tests (must pass at base commit)
- `./test.sh new` runs ONLY new tests (must fail before solution)
- NO package installs in test.sh (use Dockerfile)
- Exclude flaky tests from base if needed

**Patch Format:**
```diff
diff --git a/test.sh b/test.sh
new file mode 100755
index 0000000..abc1234
--- /dev/null
+++ b/test.sh
@@ -0,0 +1,N @@
+[test.sh content]
```

## Dockerfile

**Must start with:**
```dockerfile
FROM public.ecr.aws/x8v8d7g8/mars-base:latest
```

**Structure:**
```dockerfile
FROM public.ecr.aws/x8v8d7g8/mars-base:latest

WORKDIR /app

COPY . .

RUN [install dependencies here]

CMD ["bash"]
```

**Requirements:**
- All package installs in Dockerfile, not test.sh
- No comments
- Tests run offline
- Do NOT reference test.sh or test.patch in Dockerfile (no COPY/RUN/chmod for them)
- End with `CMD ["bash"]` or `CMD ["/bin/bash"]` (or equivalent interactive shell)

## solution.patch

Unified diff implementing the fix.

**Requirements:**
- NO comments
- Minimal, focused changes
- Match repository code style
- Must make `./test.sh new` pass

**Format:**
```diff
diff --git a/path/to/file.py b/path/to/file.py
--- a/path/to/file.py
+++ b/path/to/file.py
@@ -X,Y +X,Z @@
 context line
-removed line
+added line
 context line
```

## Verification Before Presenting

1. Check patch syntax (valid unified diff)
2. Ensure no comments in any file
3. Verify test.sh exists at repo root, is mode 100755, and has both base and new modes
4. Confirm Dockerfile uses correct base image and does not reference test.sh or test.patch

## Problem/Test Alignment Checklist

- Every claim in problem.md is directly covered by at least one new test
- Remove or trim any untested claims early
- Avoid introducing requirements not exercised by tests

## Test Quality Rubric

- Coverage: tests exercise core behavior and at least one edge case
- Leakage: tests do not hint at implementation details or solution strategy
- Over-constraint: tests avoid unnecessarily narrow assertions that block valid implementations
- Cleanup: tests leave no residual state or require external resources

## Problem/Test Alignment Checklist

- Every claim in problem.md is directly covered by at least one new test
- Remove or trim any untested claims early
- Avoid introducing requirements not exercised by tests

## Test Quality Rubric

- Coverage: tests exercise core behavior and at least one edge case
- Leakage: tests do not hint at implementation details or solution strategy
- Over-constraint: tests avoid unnecessarily narrow assertions that block valid implementations
- Cleanup: tests leave no residual state or require external resources

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

./test.sh --output_path <path> {base|new}
```

**test.sh Rules:**

* Accept `--output_path <path>` and write JUnit XML to the specified path.
* Use the project's native JUnit output or a standard JUnit library. **Do not hand-write XML.**
* `./test.sh --output_path results.xml base` runs existing tests as a regression check. Must pass.
* `./test.sh --output_path results.xml new` runs only new or modified tests. Must fail before the solution patch is applied.
* NO package installs in `test.sh` (use Dockerfile).
* Exclude flaky tests from `base` if needed.


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

**Must start with the appropriate Olympus base image for the repository's language:**

```dockerfile
FROM public.ecr.aws/d3j8x8q7/olympus-base-<language>:latest
```

Supported languages:

* Python: `olympus-base-python`
* TypeScript / JavaScript: `olympus-base-typescript`
* Go: `olympus-base-go`
* Rust: `olympus-base-rust`
* Java (JVM): `olympus-base-jvm`
* C++: `olympus-base-cpp`

**Structure:**

```dockerfile
FROM public.ecr.aws/d3j8x8q7/olympus-base-<language>:latest

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

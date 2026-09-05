---
name: github-problem-finder
description: Find difficult bugs, feature requests, or enhancements in GitHub repositories that AI agents cannot easily solve. Creates problem descriptions, test patches, dockerfiles, and solution patches for coding challenge platforms. Use when user asks to find problems in repos, create coding challenges, or evaluate problem difficulty for AI benchmarking.
---

# GitHub Problem Finder

Find and document difficult, complex problems from GitHub repos that AI agents cannot easily solve for AI benchmarking platforms.

## Mandatory Platform Contract

The original platform syntax and deliverable rules are authoritative. The multi-agent validation architecture is additive and MUST NOT replace, weaken, reinterpret, or omit these rules.

The fixed platform rules summarized in this `skill.md` are always authoritative. Load deeper references progressively instead of reading every reference at startup:

- **Discovery / pre-PD gates:** load `examples/` and `references/checks.md` only as needed to judge difficulty and platform fit. Run the Accepted Candidate, Upstream, and Prototype Footprint gates defined in this skill before final selection.
- **Before writing `problem.md`:** load `references/formatting.md` and `references/problem-writing.md`.
- **After user approval:** load `references/deliverables.md`, `references/test-writing.md`, `references/solution-writing.md`, and `references/subagent-runtime.md`.
- **Miyamura:** load `references/test-validator.md` when beginning test validation.
- **Witcher:** load `references/solution-validator.md` when beginning solution validation.
- **Docker verification:** load `references/docker-verification.md` only when Docker verification is actually requested.

Do not repeatedly reload reference files already understood unless the relevant rule is uncertain or the artifact changed in a way that requires re-checking it. If validator advice conflicts with a fixed platform syntax rule, preserve the platform syntax rule and solve the quality issue another way.

### problem.md fixed rules

- Include a clear problem title.
- Prefer `problem.md` under 200 words when the behavior can be specified completely and fairly within that space. Completeness and fairness take priority over brevity; use additional detail when necessary, up to the platform hard maximum of 1000 words. Never omit, weaken, or make a requirement ambiguous merely to stay under 200 words.
- Use valid UTF-8 only with no non-ASCII characters.
- No motivational backstory.
- Describe user-visible behavior and must-have requirements, not implementation.
- Do not include pseudocode, code snippets, regexes, shell commands, procedural steps, test names/files, repository conventions, or unnecessary backward-compatibility notes.
- Include method signatures only when they are not obvious from the repository.

### test.patch fixed rules

`test.patch` MUST be a valid unified diff and MUST include `test.sh` plus the new/modified test files.

Required invariants:

- NO comments in any file added by the task.
- Tests fail without `solution.patch` and pass with it.
- Tests work offline with no network access.
- Tests are non-redundant and follow repository test style and conventional method names.
- Aim for full problem coverage, not a trivial single-case test.
- `test.sh` is at repository root and has file mode `100755`.
- Generate the patch using `git diff --cached`.

Required `test.sh` interface:

```bash
#!/bin/bash
set -e

./test.sh --output_path <path> {base|new}
```

`test.sh` MUST:

- accept `--output_path <path>`;
- write JUnit XML to that path;
- use the project's native JUnit output or a standard JUnit library/converter;
- NEVER hand-write JUnit XML;
- make `./test.sh --output_path results.xml base` run existing regression tests and pass;
- make `./test.sh --output_path results.xml new` run only new/modified tests and fail before the solution is applied;
- install NO packages; dependencies belong in Dockerfile;
- preserve genuine framework assertion/failure diagnostics;
- exclude flaky existing tests from `base` only when necessary.

The patch entry for a new `test.sh` must retain executable mode, e.g.:

```diff
diff --git a/test.sh b/test.sh
new file mode 100755
index 0000000..abc1234
--- /dev/null
+++ b/test.sh
@@ -0,0 +1,N @@
+[test.sh content]
```

### Dockerfile fixed rules

The Dockerfile MUST start from the appropriate Olympus base image:

```dockerfile
FROM public.ecr.aws/d3j8x8q7/olympus-base-<language>:latest
```

Use exactly the matching language family:

- Python: `olympus-base-python`
- TypeScript / JavaScript: `olympus-base-typescript`
- Go: `olympus-base-go`
- Rust: `olympus-base-rust`
- Java / JVM: `olympus-base-jvm`
- C++: `olympus-base-cpp`

Required structure/pattern:

```dockerfile
FROM public.ecr.aws/d3j8x8q7/olympus-base-<language>:latest

WORKDIR /app
COPY . .

RUN [install dependencies here]

CMD ["bash"]
```

Dockerfile MUST:

- contain all dependency/package installation needed by tests;
- contain no comments;
- support offline test execution after the image is built;
- NOT reference `test.sh` or `test.patch` in Dockerfile commands, including no COPY/RUN/chmod for them;
- end with `CMD ["bash"]`, `CMD ["/bin/bash"]`, or an equivalent interactive shell.

### solution.patch fixed rules

- Valid unified diff.
- NO comments.
- Minimal, focused changes only.
- Match repository code style.
- Must make the new tests pass.
- No irrelevant changes, hardcoding, test gaming, regressions, or AI-generated artifacts.

### Verification-before-presenting fixed rules

Before presenting deliverables, always verify:

1. patch syntax is valid;
2. no forbidden comments were introduced;
3. `test.sh` exists at repo root, is mode `100755`, and supports both `base` and `new`;
4. `test.sh` supports the required `--output_path` JUnit interface;
5. Dockerfile uses the correct Olympus base image;
6. Dockerfile does not reference `test.sh` or `test.patch`;
7. every claim in `problem.md` is directly covered by at least one meaningful new test;
8. no test introduces a requirement absent from or undiscoverable from the task/repository.

### Docker verification command contract

When Docker verification is requested, follow `references/docker-verification.md` EXACTLY and in order:

```bash
git apply test.patch
docker build -t <<repo name>> .
docker run -t --network=none <<repo name>> ./test.sh base
docker run -t --network=none <<repo name>> ./test.sh new
git apply solution.patch
docker build -t <<repo name>> .
docker run -t --network=none <<repo name>> ./test.sh base
docker run -t --network=none <<repo name>> ./test.sh new
```

Expected states: `base` passes before solution; `new` fails before solution; after applying `solution.patch`, both `base` and `new` pass.

### Platform checks

Preserve the original `references/checks.md` requirements and priority order. In particular, prioritize:

1. `Problem AI difficulty`
2. `holistic_ai_judge`

Do not sacrifice fixed platform syntax to satisfy a validator or secondary check.

## Agent Architecture

The main agent is the builder and orchestrator. Deep validation must be delegated so the main context is not overloaded.

This skill requires Codex multi-agent support for delegated validation. Before the first validation gate, read `references/subagent-runtime.md` and use the built-in `spawn_agent`, `send_input`, `wait_agent`, and `close_agent` tools.

After the user approves `problem.md`, spawn exactly two validator subagents once and keep them alive for the rest of the candidate lifecycle:

1. **Miyamura** - the Test Validator.
2. **Witcher** - the Solution Validator.

Reuse these same two live validator contexts for every later audit round. Do not close and respawn them merely to obtain a new audit.

Miyamura recursively audits `problem.md` + `test.patch` using `references/test-validator.md`. Witcher recursively audits `problem.md` + `solution.patch` using `references/solution-validator.md`.

Do not merely role-play these validators inside the main context. A delegated PASS is valid only if it came from an actual spawned subagent. If the required multi-agent tools are unavailable, stop the validation gate and tell the user multi-agent support must be enabled; do not silently downgrade to main-agent self-validation.

Do not create extra validator roles unless the user explicitly requests them.

### Delegation Rule

The main agent must NOT duplicate the exhaustive validator audits. The main agent should:

- inspect the repository once to identify the core affected subsystem, likely files, relevant existing tests, and public behavior
- run the pre-PD non-plagiarism, upstream/public-solved, and throwaway prototype footprint gates
- create `problem.md`, `test.patch`, Dockerfile, `test.sh`, and `solution.patch`
- run deterministic platform/harness checks itself
- send the relevant artifacts plus the initial repository map to validators
- fix concrete validator findings
- send updated artifacts back to the same live validators and require complete current-state re-audits until the acceptance gate is satisfied

Avoid repeated whole-repository reconnaissance. Miyamura and Witcher should begin from the main agent's repository map and expand into additional files only when a concrete audit question requires it. Validators are adversarial critics, not helpers. They must actively try to disprove the candidate or artifact.

### Persistent Validator Lifecycle

Spawn Miyamura and Witcher once per candidate and keep both alive until end-to-end validation is complete. Fresh audit is mandatory; fresh agent is not.

After the main agent applies fixes, use `send_input` to give the updated current artifacts/instructions to the same validator contexts, then `wait_agent` for the next verdict. Do not close and respawn them between ordinary audit rounds.

Every round must still be a complete current-state audit. Validators must treat the latest artifacts as authoritative, re-run their full audit contract, actively search for new defects beyond earlier findings, and must not return PASS merely because previous findings were fixed. Previous findings may inform context but must not constrain the search space.

A task is complete only when Miyamura and Witcher each return the required High-confidence PASS on the latest complete current-state audit and the final platform checks pass. Close both validators after end-to-end validation is complete, or earlier only if the candidate workflow itself is finished and no further validation is required.

## Subagent Runtime Preflight

After `problem.md` is approved and before creating further deliverables, verify the runtime exposes `spawn_agent`, `send_input`, `wait_agent`, and `close_agent`. Follow `references/subagent-runtime.md` exactly for the persistent Miyamura/Witcher lifecycle.

The skill itself does not define these as shell/Python functions; they are Codex runtime tools. The validator prompt is passed through the `message` field of each `spawn_agent` call, so the spawned agent receives its role and audit contract directly.

Use `fork_turns: all` unless the live runtime requires another supported value. Use the fixed task names `miyamura` for the Test Validator and `witcher` for the Solution Validator. Store the returned agent identifiers/handles. For later rounds, use `send_input` with the existing validator target, then `wait_agent`; do not spawn duplicate Miyamura/Witcher contexts while the originals are still active.

## Accepted Candidate Ledger

The main agent maintains a compact **Accepted Candidate Ledger** across repeated candidate searches in the same session. The ledger is internal working state only and MUST NOT be added to platform deliverables.

When the user clearly accepts the current candidate and asks for another (for example, “good job, make another candidate”), treat the current candidate as accepted before starting discovery again. If Miyamura/Witcher are still live, close them for the completed candidate. Record a compact fingerprint containing:

- problem title / one-line behavior summary
- core invariant or root-cause theme
- affected subsystem and important APIs
- major implementation path / benchmark concept
- major files or components
- prototype and final meaningful solution LOC when known
- upstream-gate result
- concepts that a later candidate must not substantially duplicate

Before considering every later candidate, compare it against all ledger entries. A different issue number, title, wording, or file is NOT enough: reject a provisional candidate if it substantially duplicates a prior candidate's behavior/invariant, root cause, API change, implementation path, affected feature, or benchmark concept. Similar difficulty and ~300-400 meaningful LOC scope are encouraged; conceptual plagiarism is not.

To protect this memory during long sessions/context compression, keep the ledger compact and, when scratch-file access is available, mirror it to a temporary file **outside the repository working tree**. Never stage, commit, or include that scratch ledger in any deliverable. The main agent owns this ledger; candidate-specific Miyamura/Witcher contexts do not carry prior-candidate history.

## Workflow

1. **Read Examples First** - Load `examples/` to understand the difficulty threshold; avoid unrelated reference loading.
2. **Discover a Provisional Candidate** - Perform one focused repository reconnaissance pass and compare it against the Accepted Candidate Ledger.
3. **Run the Upstream Gate** - Search upstream/public sources before committing to the candidate. Publicly solved or substantially matching behavior/API is an immediate pre-PD rejection.
4. **Run the Prototype Footprint Gate** - Build a throwaway minimal genuine solution prototype, measure meaningful production-code LOC, require `>300` meaningful LOC without padding/overbuilding, then completely discard the prototype. Target roughly 300-400 meaningful LOC.
5. **Select + Write `problem.md` Immediately** - Only after both pre-PD gates pass, lock the candidate and immediately draft `problem.md`.
6. **Mandatory Approval Gate** - STOP after `problem.md`; present it and wait for explicit user approval before creating any further deliverable or spawning validators.
7. **Spawn Validators Once** - After approval, spawn persistent Miyamura and Witcher and immediately give them parallel repo/problem analysis work.
8. **Build + Validate in Parallel** - Main builds `test.patch`, `solution.patch`, Dockerfile, and `test.sh`; Miyamura begins full test audit as soon as `test.patch` exists, Witcher begins full solution audit as soon as `solution.patch` exists, and Main validates Dockerfile/test.sh deterministically as soon as they exist.
9. **Targeted Fix Loop** - Fix blocking findings, run focused affected checks, and use delta-first complete re-audits with the same validators. Do not loop on Low or discretionary T3/T4 findings.
10. **Final Verification Gate** - Once blocking findings are clear, run the complete required local/platform verification; run the full Docker base/new/solution sequence only if Docker verification is requested.
11. **Close Validators** - Close Miyamura and Witcher after end-to-end validation is complete.
12. **Repeat on Acceptance** - If the user accepts the candidate and asks for another, snapshot it into the Accepted Candidate Ledger and restart from Step 2 with the same gates.

If any warning or error would lower the problem's difficulty/complexity, tell the user immediately before proceeding.

## Step 1: Find Problem + Pre-PD Gates

Identify a real-world engineering problem in the repository. Treat candidates as **provisional** until the non-plagiarism, Upstream, and Prototype Footprint gates pass. Only then is the candidate finally selected/locked and `problem.md` written.

Prioritize problems that are:

- Cross-cutting and substantial - the task should require changes across multiple files or modules, not a small isolated edit
- Long-horizon - the smallest natural solution should require sustained reasoning and implementation effort across at least 3+ files
- Meaningful in scope - target roughly **300-400 meaningful production-code LOC**, with a hard pre-PD lower bound of **more than 300 meaningful LOC** demonstrated by the throwaway prototype
- Hard but solvable - target at least 1 genuine rollout solve while keeping the expected pass rate within 1-5/10; difficulty must come from reasoning and implementation depth, not ambiguity or hidden requirements
- Grounded in the real codebase - prefer missing capabilities, architectural gaps, incomplete workflows, and complex bugs over artificial or toy tasks
- Distinct from accepted candidates - substantially different in behavior/invariant, root cause, API change, implementation path, affected feature, and benchmark concept

Use the repository to discover such problems by:

- reviewing open issues such as `bug`, `enhancement`, and `feature-request`
- searching TODO/FIXME comments and partially implemented workflows
- inspecting complex or fragile areas that may require coordinated multi-file changes
- exploring the code directly to uncover difficult, meaningful problems even when no issue/TODO points to them

Avoid:

- single-function fixes
- trivial UI or CRUD changes
- narrow refactors without externally visible behavior change
- tasks that can be solved in one file or with minimal reasoning
- candidates that reach the LOC threshold only through optional refactors, abstraction churn, defensive overbuilding, generated code, or padding

Tests must ultimately be able to validate observable behavior fairly; any correct solution must be capable of passing, and all required behavior must be stated or reasonably discoverable.

### Accepted-Candidate Non-Plagiarism Gate

Before investing in the upstream audit or prototype, compare the provisional candidate with the Accepted Candidate Ledger. Drop the provisional candidate and continue discovery if its underlying benchmark concept substantially overlaps a previous accepted candidate. Do not compare only titles/files; compare the actual behavior, invariant, root cause, public/API change, and implementation path.

### Upstream Gate - Mandatory Before `problem.md`

Run this gate on every provisional candidate before committing to it:

1. **Upstream repo audit** - Search issues, PRs, commits, changelog, releases, and docs.
2. **Adjacent ecosystem audit** - Search likely parent/inspiration libraries and competitors, especially when the repository explicitly says it is inspired by them.
3. **API-name audit** - Search the exact proposed names before committing to a PD: option names, view names, callback names, helper names, and other distinctive API terms.
4. **Issue-link audit** - Open every linked issue/comment/reference and check whether maintainers point to an existing implementation elsewhere.
5. **Public-solved rejection rule** - If the feature/fix exists publicly with substantially matching behavior/API, drop the provisional candidate immediately, even if the target repository has not implemented it.

This upstream/public-solved rule is a **pre-selection gate**, not later candidate abandonment. Once a candidate passes this gate, passes the prototype footprint gate, and `problem.md` is created for approval, keep/refine that candidate unless the user explicitly asks to replace it.

### Prototype Meaningful-LOC Gate - Mandatory Before `problem.md`

Do not estimate solution size from intuition. Create a **throwaway minimal solution prototype** solely to measure the genuine implementation footprint. This is NOT `solution.patch` and MUST NOT be preserved as a deliverable.

Prototype procedure:

1. Starting from a clean candidate baseline, implement the **smallest natural end-to-end production-code solution** that follows existing repository patterns and covers all major required implementation paths. It may be unpolished, but it must be structurally complete enough that no major integration branch is still hypothetical.
2. Inspect the temporary diff and measure **meaningful production-code LOC**. Count substantive added/deleted/modified code implementing the behavior. Exclude tests, comments/docs, imports-only churn, formatting, generated code, mechanical renames, copied boilerplate, optional refactors, speculative abstractions, and any padding/overbuilding.
3. Record internally: touched production files/components, meaningful LOC per area, meaningful total, excluded non-meaningful diff, and confidence that the prototype represents the minimal maintainable solution.
4. The candidate passes only when the demonstrated meaningful total is **>300 LOC without padding or overbuilding**. Prefer candidates naturally landing around **300-400 meaningful LOC**.
5. If the minimal genuine prototype is `<=300` meaningful LOC, discard that provisional candidate and continue discovery. Never enlarge the implementation merely to cross the threshold.
6. After measurement, **discard/reset the entire prototype completely** and verify the working tree is back to the intended clean baseline. Do not stage it, save it as `solution.patch`, leak it into `problem.md`, or expose prototype implementation details to later validators.

The prototype is the scope evidence. After the real `solution.patch` is eventually created, compare its actual meaningful LOC with the prototype as a sanity check; a large unexplained divergence is a signal to review scope, not an excuse to pad the final solution.

### Final Selection Criteria

Before writing `problem.md`, all must be true:

- candidate is materially distinct from all Accepted Candidate Ledger entries
- Upstream Gate passes with no substantially matching public solution/API
- prototype demonstrates `>300` meaningful production-code LOC without padding; ~300-400 is preferred
- solution naturally spans at least 3 meaningful files/components where the repository architecture warrants it
- problem remains hard but fair and reasonably solvable
- no major required behavior depends on hidden/undiscoverable knowledge
- difficulty has been compared against the examples/evals before lock-in

Only now **select/lock the candidate**. Immediately proceed to Step 2 and write `problem.md`; do not perform additional implementation work before the approval gate.

## Step 2: Create problem.md Immediately

Immediately after the provisional candidate passes the non-plagiarism, Upstream, and Prototype Footprint gates and is selected/locked, create `problem.md` before spawning validators or creating any other deliverable. Use `references/formatting.md` and `references/problem-writing.md` for all problem.md requirements and tips.

Prefer a concise description under 200 words when the task can be specified completely and fairly within that space. Completeness and fairness take priority over brevity; use additional detail when necessary, up to the platform hard maximum of 1000 words. Never omit, weaken, or make a requirement ambiguous merely to stay under 200 words.

### Mandatory Approval Gate

**STOP immediately after writing `problem.md`.** Present `problem.md` and state whether the problem is a feature request, bug, or enhancement, then wait for explicit user approval such as `go ahead`.

Before approval, DO NOT:

- spawn Miyamura or Witcher
- create or modify `test.patch`
- create or modify `solution.patch`
- create Dockerfile or `test.sh`
- begin any deliverable/reference implementation or delegated validation work; the mandatory pre-PD throwaway prototype must already be fully discarded and MUST NOT be continued or reused

If the user requests changes, revise only `problem.md` and stop again for approval. Do not proceed to further deliverables until the current `problem.md` is explicitly approved.

## Step 3: Spawn Validators and Create Deliverables

Only after user approval, run the multi-agent runtime preflight and spawn the two persistent validators once:

- **Miyamura** - Test Validator
- **Witcher** - Solution Validator

Keep both alive for the remaining end-to-end validation lifecycle. Immediately give each validator a preliminary analysis task, then create the remaining deliverables in parallel.

Give both validators the main agent's focused repository map: affected subsystem, likely changed files, relevant existing tests, public APIs/behavior, and any known lifecycle or integration boundaries. They should expand beyond this map only when a concrete audit question requires it.

- **Miyamura** studies `problem.md`, the repository map, relevant existing tests, and public behavior; maps requirements, likely mutants, boundaries, lifecycle/state interactions, and coverage risks while the main agent builds `test.patch`.
- **Witcher** studies `problem.md`, the repository map, relevant implementation paths, callers, invariants, repository conventions, and regression risks while the main agent builds `solution.patch`.
- These preliminary analyses are preparation only. Full PASS/FAIL verdicts must wait until the relevant patch exists and a complete current-state audit is performed.

### Deliverable Construction

After user approval and after Miyamura/Witcher have been spawned and given their preliminary tasks, the main agent creates the deliverables while both validators analyze in parallel. Load `references/deliverables.md`, `references/test-writing.md`, and `references/solution-writing.md` at this stage.

Use artifact-triggered validation instead of waiting for every deliverable to finish:

- As soon as `test.patch` exists, send it to Miyamura and start the full test audit even if the solution or harness is still being finished.
- As soon as `solution.patch` exists, send it to Witcher and start the full solution audit even if the test audit is still running.
- As soon as Dockerfile and `test.sh` exist, the main agent checks their deterministic platform contract immediately: image family, root location, executable mode, `base/new`, `--output_path`, real JUnit path, no installs in `test.sh`, no forbidden Dockerfile references, and offline compatibility.

Do not wait for all four artifacts before beginning useful validation. Do not change or relax any syntax, formatting, patch, Dockerfile, test.sh, JUnit, offline, or platform requirements from the reference files.

## Step 4: Recursive Validation Gate

After `test.patch` and `solution.patch` exist, coordinate the artifact-triggered audits already started in Step 3. Do not automatically start duplicate full audits if Miyamura or Witcher is already auditing the current patch. If an audit has not started yet, dispatch it now. Keep exhaustive validation out of the main context.

### Miyamura — Test Validator

If Miyamura is not already auditing the current `test.patch`, send the patch-validation task using `send_input`; otherwise wait for the in-progress result. Miyamura must apply `references/test-validator.md` in **Patch Mode** and perform a complete current-state audit.

Provide:

- `problem.md`
- `test.patch`
- relevant repository code
- existing tests and public behavior needed to judge regressions/discoverability

Miyamura owns exhaustive T1-T13 analysis, requirement-to-test mapping, mutant analysis, behavioral-dimension sweeps, lifecycle/state coverage, interaction coverage, negative-space coverage, fairness, over-pinning, execution integrity, and recursive coverage-gap discovery.

#### T3/T4 Coverage Triage

For **T3/T4 coverage findings only**, Miyamura must assign one of three tiers:

- **High — Blocking:** A materially incorrect or incomplete solution can realistically pass. Must be fixed before PASS.
- **Medium — Discretionary:** Meaningful extra coverage, but core required behavior is already strongly protected. The main agent decides whether the value justifies adding it.
- **Low — Ignore:** Marginal, redundant, highly defensive, or unlikely to improve discrimination. Do not change tests for it.

Do not keep expanding tests solely to eliminate Medium or Low T3/T4 findings. A T3/T4 re-audit loop is mandatory only after fixing a High finding or when the main agent chooses to implement a Medium finding. Miyamura may return `PASS — no blocking coverage gaps` when zero High T3/T4 gaps remain and the remaining Medium/Low notes do not enable a realistic false-positive solution.

This triage does not weaken other test-quality rules: unfair tests, undiscoverable requirements, broken execution/reporting, over-pinning, or other non-T3/T4 defects remain blocking according to their normal severity.

### Witcher — Solution Validator

If Witcher is not already auditing the current `solution.patch`, send the solution-validation task using `send_input`; otherwise wait for the in-progress result. Witcher must apply `references/solution-validator.md` and perform a complete current-state audit.

Provide:

- `problem.md`
- `solution.patch`
- relevant repository code and callers
- existing tests or conventions needed to judge regressions and consistency

Witcher owns exhaustive S1-S12 analysis, requirement completeness, root-cause correctness, state/lifecycle correctness, cross-component consistency, regression analysis, failure behavior, concurrency/async ordering where relevant, scope discipline, and repository conformity.

### Validation Loop

Run both validators independently and in parallel whenever possible. Keep their outputs concise and actionable.

Maintain a small audit ledger in the main context, for example `T4-H1 fixed`, `T4-M2 skipped`, `S2-H1 fixed`. Resolved findings should not be re-explained unless they regress; the ledger is for coordination only and never replaces a complete audit.

For every round:

1. Receive concise concrete findings from both validators: category/severity, exact gap, one realistic failing or surviving-bad case, and the minimum required fix. Avoid essays.
2. Fix every valid blocking finding. For Miyamura T3/T4 findings: **High must be fixed, Medium is the main agent's call, Low is ignored**. For other validator categories, preserve their normal blocking severity rules.
3. During iteration, run the smallest focused tests/checks that exercise the changed behavior. Do not repeatedly run the full base/new/Docker matrix after every small edit unless a platform/harness change requires it.
4. Send only the updated artifacts/diff plus any necessary changed context back to the same validators. Require a **delta-first, complete current-state re-audit**: inspect what changed first, then perform the full confidence sweep required by the validator contract.
5. Require each validator to search for genuinely new gaps beyond earlier findings. Previous findings may guide attention but must not limit the search. Do not spend tokens re-reporting resolved issues unless they have reappeared.
6. Continue until there are no blocking findings and both validators return PASS **with `Confidence: High` under their validator PASS contracts** on the latest artifacts. Miyamura may still report non-blocking Medium T3/T4 notes; these do not prevent acceptance unless the main agent judges that they enable a realistic false positive. A PASS without High confidence is not an acceptance.
7. Near completion, run the full required local/platform verification once against the final artifacts. If Docker verification was explicitly requested, run the exact full Docker base/new/solution sequence at this point.
8. If final verification forces any change to `problem.md`, `test.patch`, or `solution.patch`, send only the changed artifact/diff back to the affected validator and require another High-confidence current-state audit. If verification causes no artifact change, do not spend tokens on a redundant second PASS audit.
9. Once end-to-end validation is complete, close Miyamura and Witcher with `close_agent`.

If a validator repeatedly reports the same issue, fix the underlying invariant rather than patching only the cited example. Prefer a small number of high-discrimination tests that kill broad classes of bad implementations over many shallow edge-case tests.

The acceptance burden is asymmetric: findings require one concrete defect, but PASS requires affirmative evidence that the complete required audit was performed and survived. The main agent must reject superficial PASS verdicts such as `looks good`, `seems comprehensive`, or PASS without the required confidence/basis lines.

### Acceptance Gate

Do not present the final task unless all are true:

- every explicit behavioral promise in `problem.md` has meaningful semantic test coverage
- no concrete plausible materially incorrect implementation associated with a blocking test finding can pass
- no **High/blocking T3/T4** coverage gap remains; Medium T3/T4 findings are discretionary and Low findings are ignored unless the main agent determines they enable a realistic false positive
- no blocking non-T3/T4 boundary, lifecycle, state, interaction, sibling-path, negative-space, fairness, execution, or regression gap remains
- tests do not require unspecified or undiscoverable behavior
- tests do not over-pin incidental output or implementation details
- tests work offline and preserve real failure diagnostics
- the solution satisfies every stated requirement
- the solution fixes the underlying behavior rather than only the demonstrated example
- no concrete regression or required-path omission remains
- solution changes are relevant, repository-conventional, and free of AI-generated artifacts
- both persistent validators pass the latest complete current-state audit with High confidence

## Post-Rollout Calibration (When Rollout Results Are Provided)

Use rollout ZIPs/summaries to calibrate solvability without weakening discrimination. The target is **1-5/10 genuine passes**.

If the first rollout cycle is `0/10`:

1. inspect all rollout summaries, prioritizing the strongest near-pass and any blocker repeated across multiple agents;
2. add the **smallest high-confidence implementation hint** to `problem.md` that addresses the common conceptual/implementation bottleneck;
3. prefer a useful directional hint over a vague one, but do not reveal exact code or the complete reference solution;
4. treat test changes as the **last resort** and change tests only if rollout evidence shows they are unfair, incorrect, over-pinned, or require undiscoverable behavior;
5. before using the hint, verify it creates no new blocking T1-T12/S1-S12 gap and does not create a false-positive path. At least two plausible incorrect implementations that follow the hint should still be rejected by the tests;
6. use rollout evidence to justify why the hint is likely to convert at least one failure into a genuine pass while keeping the expected pass rate at or below `5/10`.

If Miyamura/Witcher are still live, reuse them for the hint safety audit. If they were already closed, respawn only Miyamura and Witcher for this calibration audit, then close them when the hint is validated. Never replace the selected candidate because of rollout difficulty; refine the same candidate.

If the next cycle lands at `1-5/10` genuine passes, keep the task unless another quality defect exists. If it exceeds `5/10`, first reduce an over-strong hint or audit test discrimination; do not intentionally make requirements ambiguous.

## Step 5: Docker Verify (Optional)

Only if user requests. Follow `references/docker-verification.md` exactly.

## Handling Check Feedback

User may provide check errors/warnings. Priority order:

1. `Problem AI difficulty`
2. `holistic_ai_judge`

When the user supplies rollout/check feedback, calibrate toward **1-5/10 genuine passes**. `0/10` is a solvability-calibration signal, not an acceptable final target; more than `5/10` indicates the task may be over-guided or insufficiently discriminating.

If checks conflict, find middle ground. Make minimal changes as fixes for one check may break another. Flag conflicts before making changes.

# Codex Subagent Runtime Contract

This skill uses Codex's built-in multi-agent tools. It does **not** implement subagents with shell/Python scripts.

## Required runtime capability

Codex must expose:

- `spawn_agent`
- `send_input`
- `wait_agent`
- `close_agent`

Multi-agent support is normally enabled in `~/.codex/config.toml` with:

```toml
[features]
multi_agent = true
```

If these tools are unavailable, do not pretend validation was delegated. Stop the delegated-validation gate and tell the user multi-agent support must be enabled.

## Persistent validator protocol

After the user manually updates `humanized_prompt.md` and confirms `go ahead`, spawn Miyamura and Witcher **once**. Spawn FP Validator later, as soon as both `test.patch` and `solution.patch` exist:

### Miyamura - Test Validator

```text
task_name: miyamura
fork_turns: all
message: |
  You are Miyamura, the Test Validator for github-problem-finder.
  Read and obey references/test-validator.md.

  Treat `humanized_prompt.md` as the authoritative task contract. First perform preliminary repository/contract analysis while the main agent builds test.patch.
  Map requirements, likely bad implementations, boundaries, lifecycle/state interactions, sibling paths, and coverage risks.

  When test.patch is provided, switch to Patch Mode and perform the complete adversarial audit.
  PASS is exceptional and requires Confidence: High under the validator contract.
  Do not spawn additional agents.
```

### Witcher - Solution Validator

```text
task_name: witcher
fork_turns: all
message: |
  You are Witcher, the Solution Validator for github-problem-finder.
  Read and obey references/solution-validator.md.

  Treat `humanized_prompt.md` as the authoritative task contract. First perform preliminary repository/contract analysis while the main agent builds solution.patch.
  Trace affected implementation paths, callers, invariants, lifecycle behavior, sibling paths, and regression risks.

  When solution.patch is provided, perform the complete adversarial solution audit.
  PASS is exceptional and requires Confidence: High under the validator contract.
  Do not spawn additional agents.
```

Store both returned agent handles.

### FP Validator - False Positive / Reference Scope Validator

Once both patches exist, spawn:

```text
task_name: fp_validator
fork_turns: all
message: |
  You are the False Positive Validator for github-problem-finder.
  Read and obey references/false-positive-validator.md.

  Treat humanized_prompt.md as the authoritative task contract.
  You have exactly two jobs: find meaningful required public behavior implemented by the reference solution that current tests do not distinguish, and find meaningful reference behavior outside the active contract that should be trimmed.

  Do not become a general coverage reviewer or solution reviewer. Do not make tests airtight. High blocks, Medium is pass-with-caveat, Low is ignored. Preserve the target of at least one genuine rollout solve and ideally 1-5/10 passes.
  Do not spawn additional agents.
```

Store the returned FP Validator handle and keep it alive across later relevant changes.

## Parallel lifecycle

Do not leave validators idle while the main agent creates deliverables.

- Main agent builds `test.patch`, `solution.patch`, Dockerfile, and `test.sh`.
- Miyamura performs preliminary test/coverage analysis in parallel.
- Witcher performs preliminary solution/regression analysis in parallel.
- FP Validator is not spawned until both patches exist; then it performs the reference/test differential probe in parallel with ongoing fixes.
- As soon as `test.patch` exists, use `send_input` to give the current patch to Miyamura and start the full audit.
- As soon as `solution.patch` exists, use `send_input` to give the current patch to Witcher and start the full audit.
- Use `wait_agent` to collect results when needed; do not start a duplicate full audit for an artifact already being audited.

## Re-audit protocol

Keep Miyamura, Witcher, and FP Validator alive across fix rounds once each has been spawned.

After the main agent changes an audited artifact:

1. send only the updated artifact/diff plus necessary changed context with `send_input`;
2. require a **delta-first, complete current-state re-audit**;
3. tell the validator to inspect what changed first, then re-run its full confidence contract;
4. require it to search for new defects beyond previous findings;
5. use `wait_agent` for the verdict.

Fresh audit is mandatory; fresh agent is not. Previous findings may inform attention but must not limit the new audit.

Do not close and respawn validators between normal rounds. Do not spawn duplicate `miyamura`, `witcher`, or `fp_validator` tasks while existing contexts are active.

## Result handling

Reject a PASS result that:

- lacks `Confidence: High`;
- omits the validator's required basis/evidence;
- says only `looks good`, `seems comprehensive`, or equivalent;
- admits a relevant blocking audit dimension was skipped;
- leaves a blocking material assumption unresolved.

For Miyamura T3/T4 specifically, Medium findings are discretionary and Low findings are ignored. For FP Validator, High blocks, Medium is PASS with caveat, and Low is ignored. FP Medium findings must not be promoted merely to make tests airtight.

## Closing

Close Miyamura, Witcher, and FP Validator with `close_agent` only when end-to-end validation is complete, or when no further validation for that candidate is required.

If final platform verification changes `humanized_prompt.md`, `test.patch`, or `solution.patch`, re-open the affected audits with the same live validators before closing them. Re-run FP Validator whenever a changed artifact can alter the reference/test differential. If final verification causes no artifact change, do not request a redundant second PASS audit.

For later rollout-hint calibration, reuse live validators if they are still open. Reuse or respawn FP Validator only when the hint or fixes can alter false-positive/reference-scope risk. Close any respawned validators when calibration finishes.

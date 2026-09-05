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

After `problem.md` is explicitly approved, spawn exactly two validator subagents **once**:

### Miyamura - Test Validator

```text
task_name: miyamura
fork_turns: all
message: |
  You are Miyamura, the Test Validator for github-problem-finder.
  Read and obey references/test-validator.md.

  First perform preliminary repository/problem analysis while the main agent builds test.patch.
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

  First perform preliminary repository/problem analysis while the main agent builds solution.patch.
  Trace affected implementation paths, callers, invariants, lifecycle behavior, sibling paths, and regression risks.

  When solution.patch is provided, perform the complete adversarial solution audit.
  PASS is exceptional and requires Confidence: High under the validator contract.
  Do not spawn additional agents.
```

Store both returned agent handles.

## Parallel lifecycle

Do not leave validators idle while the main agent creates deliverables.

- Main agent builds `test.patch`, `solution.patch`, Dockerfile, and `test.sh`.
- Miyamura performs preliminary test/coverage analysis in parallel.
- Witcher performs preliminary solution/regression analysis in parallel.
- As soon as `test.patch` exists, use `send_input` to give the current patch to Miyamura and start the full audit.
- As soon as `solution.patch` exists, use `send_input` to give the current patch to Witcher and start the full audit.
- Use `wait_agent` to collect results when needed; do not start a duplicate full audit for an artifact already being audited.

## Re-audit protocol

Keep Miyamura and Witcher alive across fix rounds.

After the main agent changes an audited artifact:

1. send only the updated artifact/diff plus necessary changed context with `send_input`;
2. require a **delta-first, complete current-state re-audit**;
3. tell the validator to inspect what changed first, then re-run its full confidence contract;
4. require it to search for new defects beyond previous findings;
5. use `wait_agent` for the verdict.

Fresh audit is mandatory; fresh agent is not. Previous findings may inform attention but must not limit the new audit.

Do not close and respawn validators between normal rounds. Do not spawn duplicate `miyamura` or `witcher` tasks while the existing contexts are active.

## Result handling

Reject a PASS result that:

- lacks `Confidence: High`;
- omits the validator's required basis/evidence;
- says only `looks good`, `seems comprehensive`, or equivalent;
- admits a relevant blocking audit dimension was skipped;
- leaves a blocking material assumption unresolved.

For Miyamura T3/T4 specifically, Medium findings are discretionary and Low findings are ignored. They do not invalidate PASS unless the finding actually enables a material false positive, in which case Miyamura must classify it High.

## Closing

Close Miyamura and Witcher with `close_agent` only when end-to-end validation is complete, or when no further validation for that candidate is required.

If final platform verification changes `problem.md`, `test.patch`, or `solution.patch`, re-open the affected audit with the same live validator before closing it. If final verification causes no artifact change, do not request a redundant second PASS audit.

For later rollout-hint calibration, reuse live validators if they are still open. If they were already closed, spawn only Miyamura and Witcher for that calibration audit and close them when it finishes.

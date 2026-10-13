# Update Manifest

This package is a complete superset of the original `github-problem-finder` skill.

## Preserved platform contract

The original deliverable syntax remains authoritative, including:

- `test.patch` unified-diff requirements
- executable root `test.sh` with `base/new` and `--output_path`
- real JUnit generation and preserved diagnostics
- offline execution
- Olympus Docker base images and Dockerfile restrictions
- `solution.patch` scope/style rules
- platform check priority
- exact optional Docker verification sequence

## Workflow updates

- `problem.md` is created immediately after candidate selection and frozen. The skill copies it to `humanized_prompt.md`, stops for the user to edit that file manually, and waits for `go ahead`.
- Problem descriptions target under 200 words but may use up to 1000 words when completeness/fairness requires it.
- After `go ahead`, **Miyamura** (tests) and **Witcher** (solution) are spawned immediately. A third specialist, **FP Validator**, is spawned once both patches exist.
- Validators stay alive across normal audit/fix rounds and receive updates through `send_input`; fresh audit is required, fresh agent is not.
- Validators analyze the repo/problem in parallel while the main agent builds deliverables.
- Full validation begins as soon as the relevant patch exists; duplicate full-audit dispatches are avoided.
- Re-audits are delta-first but still complete current-state audits.
- Miyamura T3/T4 findings use: High = blocking, Medium = discretionary, Low = ignore.
- A redundant second PASS audit is removed; re-audit after final verification is required only when an audited artifact changed.
- Rollout calibration targets **1-5/10 genuine passes**. `0/10` triggers the smallest high-confidence problem hint first; test changes are last resort and false-positive paths must remain blocked.
- Once selected, a candidate is refined rather than rejected/replaced because of later validation or rollout difficulty.

## Pre-PD discovery gates

- Candidate discovery is now provisional until three gates pass: Accepted-Candidate non-plagiarism, Upstream/public-solved audit, and a throwaway Prototype Meaningful-LOC gate.
- The Upstream gate searches issues/PRs/commits/releases/docs, adjacent inspiration/competitor libraries, exact proposed API names, and every linked issue/comment/reference. A substantially matching public implementation is an immediate pre-PD rejection.
- Solution scope is measured from a temporary minimal genuine implementation rather than guessed. The prototype must demonstrate `>300` meaningful production-code LOC without padding/overbuilding, with ~300-400 preferred, and is fully discarded before `problem.md`.
- `problem.md` is still created immediately after final candidate lock, then frozen. `humanized_prompt.md` becomes the downstream source of truth only after the user edits it and confirms `go ahead`.
- Accepted candidates are fingerprinted in a compact internal ledger so later candidates can match scope without duplicating the same behavior/invariant/root cause/API/implementation concept.
- When the user accepts a candidate and asks for another, the ledger is updated and the full discovery pipeline restarts.

## New/extended files

- `references/subagent-runtime.md`
- `references/test-validator.md`
- `references/solution-validator.md`
- strengthened `references/test-writing.md`
- strengthened `references/solution-writing.md`
- `scripts/check-multi-agent.sh`
- `scripts/check-multi-agent.ps1`

## Requirement-budget and description-length update

- `problem.md` now has a hard maximum of 13 total requirements. Related branches, edge cases, examples, and tests governed by the same behavior are tracked as subcases rather than inflated into separate requirements.
- Problem descriptions target 200 words or fewer. They may exceed 200 only when necessary for completeness, fairness, or clarity; the existing 1000-word platform hard maximum remains.
- Miyamura and Witcher preserve the same at-most-13 top-level requirement model during validation so grouped requirements are not later exploded into a larger requirement count.


## Manual humanized prompt source-of-truth handoff

- `problem.md` is immutable after its initial draft.
- A root-level `humanized_prompt.md` is created as an exact copy, then the workflow stops for manual user editing.
- After `go ahead`, all patch construction, Miyamura/Witcher/FP validation, acceptance, and rollout calibration use `humanized_prompt.md` as the active contract.
- Later edits and hints never sync back into the frozen `problem.md`.

## Humanized prompt handoff

- `problem.md` is frozen immediately after the initial draft.
- Root-level `humanized_prompt.md` is created as an exact copy, then the workflow stops for the user to edit it manually.
- After the user says `go ahead`, `humanized_prompt.md` becomes the sole downstream task contract for patches, validators, acceptance, rollout calibration, and hints.
- Later changes are never copied back into frozen `problem.md`.

## False Positive Validator

- Adds a third specialist subagent, `fp_validator`, spawned once both `test.patch` and `solution.patch` exist.
- It checks only two things: required public reference behavior that current tests do not distinguish, and meaningful reference overbuild outside the active contract.
- Findings are calibrated: High blocks, Medium is PASS with caveat / discretionary, Low is ignored.
- The FP validator must not make tests airtight; new tests are recommended only for material, fair false-positive risks likely to matter in platform review.
- Reference overbuild is preferably trimmed instead of expanding tests.
- Rollout solvability remains first-class: at least one genuine solve, ideally 1-5/10 passes.

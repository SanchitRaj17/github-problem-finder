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

- `problem.md` is created immediately after candidate selection, then the skill stops for explicit user approval.
- Problem descriptions target under 200 words but may use up to 1000 words when completeness/fairness requires it.
- After approval, exactly two validators are spawned: **Miyamura** (tests) and **Witcher** (solution).
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
- `problem.md` is still created immediately after final candidate lock and remains followed by the hard user-approval stop.
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

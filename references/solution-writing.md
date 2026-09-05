# Solution Writing Checklist

Use this file while constructing the solution. Exhaustive adversarial validation belongs to the Solution Validator in `references/solution-validator.md`; do not duplicate that full audit in the main agent.

- Implement every requirement in the problem statement.
- Fix the underlying invariant/root cause, not only the demonstrated reproduction.
- Avoid hardcoded values, fixture-specific branches, and test gaming.
- Preserve existing working behavior and public contracts.
- Follow repository architecture, naming, error handling, typing, formatting, and coding patterns.
- Keep the patch focused; do not make unrelated refactors, cleanup, renames, formatting churn, or speculative changes.
- Handle relevant state/lifecycle, failure, cleanup, repeated-call, and sibling-path behavior consistently.
- Do not introduce AI-generated artifacts such as weird comments, unexplained defensive code, unnecessary abstraction, or new patterns inconsistent with the repository.
- Every meaningful diff hunk must be necessary for the task or its required integration.

## Construction Questions

- Is every stated requirement implemented across all required paths?
- Does the fix address the general rule rather than only the exact test/example?
- Could any existing caller, state transition, failure path, or sibling implementation regress?
- Is state mutated at the correct time and cleaned up correctly on failure?
- Does the patch do anything not required by the problem?
- Is anything required by the problem still missing?
- Would the patch look natural to a maintainer of this repository?

The main agent should use these questions while implementing, then delegate the exhaustive recursive audit to the Solution Validator.

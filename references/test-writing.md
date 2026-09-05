# Test Writing Tips

Use this file while constructing tests. Exhaustive adversarial validation belongs to the Test Validator in `references/test-validator.md`; do not duplicate that full audit in the main agent.

- No surprise tests: everything tested must be part of the requirements or clearly discoverable from the repository.
- Strong tests: tests must reject materially inaccurate solutions, not merely prove that code executes.
- Extensive coverage: cover the requested behavior and all obvious relevant boundaries, states, interactions, negative cases, and sibling paths.
- Tests are not brittle: avoid over-constraint and implementation-specific expectations.
- Use repository-conventional method names and patterns.
- A correct implementation should pass all tests without hacks.
- Tests must work offline with `--network none`.
- Do not over-pin exact error text, messages, wording, formatting, or incidental output unless the description requires it or the repository clearly establishes it as contract.
- Keep real failure diagnostics intact. Do not hide assertion failures or upstream errors behind hardcoded catch-all reporting.
- Prefer observable behavior over private implementation details.

## Construction Questions

- Does every explicit behavioral promise have at least one meaningful assertion?
- Could a trivial, hardcoded, happy-path-only, or partial implementation pass?
- Are relevant state transitions, boundaries, negative behavior, interactions, and regressions represented?
- Are tests proving semantics rather than broad proxies such as existence, non-empty output, callback occurrence, or loose bounds?
- Are any important edge cases missing?
- Are any tests testing behavior that is not specified or discoverable?
- Are any tests brittle or unnecessarily over-pinned?
- Are there redundant or irrelevant tests that add noise without increasing discrimination?

The main agent should use these questions to build a strong first draft, then delegate the exhaustive recursive audit to the Test Validator.

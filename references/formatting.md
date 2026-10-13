# Problem Description Format

## Requirements

- Include a clear problem title
- Target 200 words or fewer; exceed 200 only when necessary for completeness, fairness, or clarity, with a hard maximum of 1000 words
- Maximum 13 total requirements. Count coherent behavioral rules, not every example, edge case, branch, or test case separately
- Combine closely related cases under one governing requirement when they express the same behavior or invariant
- If more than 13 requirements remain, regroup or narrow the description before presenting it; do not hide unrelated behaviors inside one requirement just to satisfy the cap
- Valid UTF-8 only (no non-ASCII characters)
- No motivational backstory

## Include

- What is wrong or missing (user-visible outcome)
- Primary goals and must-have behaviors
- Why (optional, brief)
- Method signatures only if they are not obvious from the repository
## Exclude

- How to implement
- Pseudocode or code snippets
- Regex patterns
- Shell commands
- Procedural steps
- References to test files/functions
- Repository conventions or de facto expectations
- Backward compatibility notes unless explicitly required
## Example (Good)

```
# Add Vary: Cookie Support for Cache Keys
The requests-cache library fails to cache responses correctly when servers send Vary: Cookie, because cookie values are not included in cache key generation. When Vary: Cookie is present or cookie matching is explicitly requested, include request cookies (cookie jar + Cookie header) in the cache key and add an ignored_cookies option on CachedSession, analogous to ignored_parameters, to filter those out of cache keys and cached request data.
When Vary: Cookie is absent and cookie matching isn't requested, continue ignoring cookies.
```
## Why This Example Works

- States what is wrong (cache fails with Vary: Cookie)
- States what should happen (include cookies in cache key)
- Mentions related feature (ignored_cookies option)
- Does NOT explain how to implement

## Manual humanized prompt handoff

`problem.md` is the immutable initial draft. Create `humanized_prompt.md` as its exact copy, then stop for the user to edit it manually. After the user confirms `go ahead`, apply the same task-format and requirement-budget rules to `humanized_prompt.md`, and treat it as the active contract without changing the original `problem.md`.

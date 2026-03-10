# Problem Description Format

## Requirements

- Include a clear problem title
- 100-200 words total
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

The requests-cache library fails to cache responses correctly when servers send Vary: Cookie, because cookie values are not included in cache key generation. When Vary: Cookie is present or cookie matching is explicitly requested, include request cookies (cookie jar + Cookie header) in the cache key and add an ignored_cookies option on CachedSession, analogous to ignored_parameters, to filter those out of cache keys and cached request data. When Vary: Cookie is absent and cookie matching isn't requested, continue ignoring cookies.
```

## Why This Example Works

- States what is wrong (cache fails with Vary: Cookie)
- States what should happen (include cookies in cache key)
- Mentions related feature (ignored_cookies option)
- Does NOT explain how to implement

# Platform Checks

## Priority Order

1. `Problem AI difficulty` - Must be genuinely hard for AI
2. `holistic_ai_judge` - AI overall assessment

## Problem Checks

| Check | Requirement |
|-------|-------------|
| description_length | 100-200 words |
| category_match | Bug/Feature/Enhancement matches content |
| Problem AI difficulty | Genuinely hard for AI |
| Problem Quality Check | Well-structured, clear |
| utf8_valid | Valid UTF-8 only |
| not_plagiarized | Original content |
| test_patch_sanity | Valid git diff format |
| test_patch_applies | Patch applies cleanly |
| description_sanity | AI validates clarity |
| quality_check | AI validates quality |
| necessary_info_only | No extraneous details |
| problem_test_alignment | Tests match description |
| dockerfile_valid | Dockerfile runs |

## Solution Checks

| Check | Requirement |
|-------|-------------|
| solution_patch_format | Valid unified diff |
| test_execution | All tests pass |
| code_quality | Matches repo style |
| holistic_ai_judge | AI overall assessment |
| problem_precision_and_alignment | Solution matches problem |

## Handling Conflicts

When checks conflict (e.g., one says remove line, another says explanation required):
1. Identify the conflict before making changes
2. Prioritize AI difficulty and holistic_ai_judge
3. Find middle ground that satisfies both
4. Make minimal changes (fix for one may break another)
5. Flag conflicts to user before proceeding

## Common Failures

1. Tests too weak - trivial implementation can pass
2. Description too detailed - reveals implementation
3. Existing PR - solution already proposed
4. Comments in files - must have NO comments

---
name: github-problem-finder
description: Find difficult bugs, feature requests, or enhancements in GitHub repositories that AI agents cannot easily solve. Creates problem descriptions, test patches, dockerfiles, and solution patches for coding challenge platforms. Use when user asks to find problems in repos, create coding challenges, or evaluate problem difficulty for AI benchmarking.
---

# GitHub Problem Finder

Find and document difficult, complex problems from GitHub repos that AI agents cannot easily solve for AI benchmarking platforms.

## Workflow

1. **Read Examples First** - Load `examples/` folder to understand difficulty threshold
2. **Find Problem** - Search repo for problems AT LEAST as difficult as examples
3. **Create problem.md** - Draft description, STOP and wait for user approval
4. **Create Deliverables** - After user says "go ahead": test.patch, Dockerfile, solution.patch
5. **Docker Verify** - Only if user explicitly requests

If any warning or error would lower the problem's difficulty/complexity, tell the user immediately before proceeding.


## Step 1: Find Problem

Identify a **real-world engineering problem** in the repository.

Prioritize problems that are:
- **Cross-cutting and substantial** — the task should require changes across multiple files or modules, not a small isolated edit
- **Long-horizon** — the expected solution should involve sustained reasoning and implementation effort, at least 3+ files changed and 400+ LOC added to the solution paatch.
- **Hard but solvable** — At least 1 agent solves it (solvable). No more than 3 solve it, with at most 1 Nova (hard). Successful runs touch 3+ files and take 100+ steps (scope), For this give description needs more clarity.
- **Grounded in the real codebase** — prefer genuine bugs, missing capabilities, architectural gaps, or incomplete workflows over artificial or toy tasks

Use the repository to discover such problems by:
- Reviewing open issues such as `bug`, `enhancement`, and `feature-request`
- Searching for TODO/FIXME comments and partially implemented workflows
- Inspecting complex or fragile areas of the codebase that may require coordinated multi-file changes
- Exploring the code directly to uncover difficult, meaningful problems even when no issue or TODO explicitly points to them

When selecting a problem, avoid:
- Single-function fixes
- Trivial UI or CRUD changes
- Narrow refactors without externally visible behavior change
- Tasks that can be solved in one file or with minimal reasoning

Also ensure the problem can support **fair testing**:
- Tests must validate observable behavior, not implementation details
- Any correct solution should be able to pass
- All requirements, constraints, and necessary interface definitions must be stated explicitly


**Difficulty Criteria** (ALL required):
- Requires understanding multiple interconnected components
- No existing PR addresses the issue
- Solution requires non-obvious implementation decisions
- Cannot be solved by simple pattern matching
- At least 3+ files edited 
- At least 400 Lines of code in the solution patch

**Verify**: Compare candidate against examples. If not as difficult, find another.

**Eval Gate**: After identifying a candidate problem, run evals to match its difficulty against the examples. If evals indicate the problem is less difficult, discard it and keep searching until a candidate meets or exceeds the example difficulty.

## Step 3: Create problem.md

Use `references/formatting.md` and `references/problem-writing.md` for all problem.md requirements and tips.

**STOP** - Present problem.md and state whether the problem is a feature request, bug, or enhancement, then wait for "go ahead"

## Step 4: Create Deliverables

After user approval. See `references/deliverables.md`.

Follow `references/deliverables.md` for all deliverable requirements, including Dockerfile/test.sh rules, offline testing, coverage expectations, alignment checks, and verification steps.
Also follow `references/test-writing.md` and `references/solution-writing.md` for quality checklists.

## Step 5: Docker Verify (Optional)

Only if user requests. Follow `references/docker-verification.md` exactly.

## Handling Check Feedback

User may provide check errors/warnings. Priority order:
1. `Problem AI difficulty`
2. `holistic_ai_judge`

When the user supplies a description of these checks (e.g., "Tests difficulty by having AI attempt to solve. Goal: 10-50% pass rate (0% ok with stricter quality). No unfair failures."), treat it as feedback about these checks and apply it accordingly.

If checks conflict, find middle ground. Make minimal changes as fixes for one check may break another. Flag conflicts before making changes.
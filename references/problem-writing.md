# Problem Writing Tips
- Keep a hard budget of **13 requirements maximum** in the final problem. Count broad coherent behavioral rules rather than splitting every edge case, branch, example, or test case into its own requirement.
- Merge closely related cases when they are governed by the same behavior or invariant. If the task still needs more than 13 requirements, narrow or regroup it before writing the final description. Do not combine unrelated behaviors only to game the count.
- Target **200 words or fewer**. Go above 200 only when required to keep the task complete, fair, and unambiguous; never exceed 1000 words.
- Write a behavioral requirement: what should happen and why, not how.
- Give just enough clarity that at least 1 Agent can solve it but not so much that it becomes too easy.
- Do not leak implementation details or solution strategy.
- Do not include anything that is obvious from the repository.
- Do not include repository conventions or default expectations.
- Do not mention backward compatibility unless the problem explicitly requires it.
- Include method signatures only if they are not obvious.
- If the code already has a method that makes an alternative obvious, do not name the alternative explicitly.

## Handoff after the draft

Once the initial `problem.md` draft is written, freeze it. Create root-level `humanized_prompt.md` as an exact copy and stop for the user to edit that copy manually. Never overwrite `problem.md` with the edited version. After the user says `go ahead`, downstream construction and validation use only `humanized_prompt.md` as the task contract.

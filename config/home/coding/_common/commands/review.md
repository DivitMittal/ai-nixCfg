## Context

- Files to review: $ARGUMENTS or staged changes
- Diff: !`git diff --cached --stat 2>/dev/null || git diff HEAD --stat`

## Task

Review the code for:

1. **Bugs**: Logic errors, edge cases, null checks
1. **Security**: Input validation, secrets, injection
1. **Performance**: Unnecessary work, memory leaks
1. **Style**: Naming, complexity, documentation

Output format:

- Critical (must fix)
- Warning (should fix)
- Suggestion (nice to have)

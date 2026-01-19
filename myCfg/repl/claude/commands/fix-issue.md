---
allowed-tools: Bash(gh:*), Bash(git:*), Read, Edit, Write
argument-hint: <issue-number>
description: Fix a GitHub issue
---
## Context

- Issue details: !`gh issue view $ARGUMENTS 2>/dev/null || echo "Could not fetch issue"`

## Task

1. Understand the issue from the description and comments
2. Create a branch named fix/$ARGUMENTS or feature/$ARGUMENTS
3. Implement the fix following project conventions
4. Test the changes if applicable
5. Commit with message referencing the issue (e.g., "fix: description (closes #$ARGUMENTS)")

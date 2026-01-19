---
allowed-tools: Bash(git:*), Bash(gh:*)
argument-hint: [title]
description: Create a pull request with description
---
## Context

- Current branch: !`git branch --show-current`
- Default branch: !`gh repo view --json defaultBranchRef -q .defaultBranchRef.name 2>/dev/null || echo "main"`
- Commits not in main: !`git log main..HEAD --oneline 2>/dev/null || git log origin/main..HEAD --oneline 2>/dev/null`
- Changed files: !`git diff main..HEAD --stat 2>/dev/null || git diff origin/main..HEAD --stat 2>/dev/null`
- Available labels: !`gh label list --limit 15 2>/dev/null | cut -f1`
- Open PRs for branch: !`gh pr list --head $(git branch --show-current) --json number,url -q '.[0].url' 2>/dev/null`

## Task

Create a pull request:
1. Check if PR already exists for this branch (skip if so, show URL)
2. Push current branch to origin if not already pushed: `git push -u origin HEAD`
3. Create PR with:
   - Title from $ARGUMENTS or infer from commits/branch name
   - Description summarizing changes (use commit messages)
   - `gh pr create --title "..." --body "..." [--label ...] [--draft] [--assignee @me]`
4. Suggest labels from available ones based on change type
5. Ask if it should be a draft PR
6. Report the created PR URL

## PR Description Template

Use this structure for the body:
```
## Summary
<brief description of changes>

## Changes
- <bullet points of key changes>

## Testing
<how to test, or "N/A" if not applicable>
```

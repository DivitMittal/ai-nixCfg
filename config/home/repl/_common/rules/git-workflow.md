# Git Workflow Rules

## Commits
- Use Conventional Commits format: `type(scope): description`
- Keep commits atomic (one logical change per commit)
- Write imperative mood ("add feature" not "added feature")
- Reference issues when applicable: `fixes #123`

## Branches
- `main` is protected - never force push
- Feature branches: `feat/description`
- Fix branches: `fix/issue-number` or `fix/description`
- Keep branches short-lived

## Before Committing
- Run `nix fmt` on changed Nix files
- Run `nix flake check` for Nix projects
- Review diff before staging

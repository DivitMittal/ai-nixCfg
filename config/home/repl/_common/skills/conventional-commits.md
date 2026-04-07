# Conventional Commits

## Format
```
<type>(<scope>): <description>

[optional body]

[optional footer(s)]
```

## Types
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation only
- `style`: Formatting, no code change
- `refactor`: Code change, no feature/fix
- `perf`: Performance improvement
- `test`: Adding/fixing tests
- `chore`: Build, tools, deps
- `ci`: CI configuration

## Scope Examples (for this repo)
- `home`: Home manager configs
- `darwin`: macOS-specific
- `nixos`: NixOS-specific
- `flake`: Flake inputs/outputs
- `module`: Custom modules
- `pkg`: Custom packages

## Examples
- `feat(home): add starship prompt configuration`
- `fix(darwin): resolve homebrew cask conflicts`

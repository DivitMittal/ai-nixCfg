<div align="center">
    <h1>ai-nixCfg</h1>
    <strong>Nix home-manager modules and configurations for AI coding assistants.</strong>
</div>

---

<div align="center">
    <a href="https://github.com/DivitMittal/ai-nixCfg/stargazers">
        <img src="https://img.shields.io/github/stars/DivitMittal/ai-nixCfg?&style=for-the-badge&logo=starship&logoColor=white&color=purple" alt="stars"/>
    </a>
    <a href="https://github.com/DivitMittal/ai-nixCfg/">
        <img src="https://img.shields.io/github/repo-size/DivitMittal/ai-nixCfg?&style=for-the-badge&logo=github&logoColor=white&color=purple" alt="size" />
    </a>
    <a href="https://github.com/DivitMittal/ai-nixCfg/blob/main/LICENSE">
        <img src="https://img.shields.io/github/license/DivitMittal/ai-nixCfg?&style=for-the-badge&logo=unlicense&logoColor=white&color=purple" alt="license"/>
    </a>
</div>

---

## Overview

This repository contains Nix home-manager modules and personal configurations for AI coding assistants, including:

- **Claude Code** - Anthropic's AI coding assistant
- **OpenAI Codex** - OpenAI's code generation CLI
- **GitHub Copilot CLI** - GitHub's AI pair programmer CLI

## Project Structure

```
.
├── flake.nix                 # Main flake entry point
├── flake/                    # Flake-parts module definitions
│   ├── checks.nix            # Pre-commit hooks
│   ├── devshells.nix         # Development shell
│   └── formatters.nix        # Code formatters
├── modules/                  # Home-manager modules (reusable)
│   └── home/
│       ├── claude-code.nix   # Claude Code module
│       ├── codex.nix         # OpenAI Codex module
│       └── github-copilot.nix # GitHub Copilot CLI module
└── myCfg/                    # Personal configurations
    ├── cli/                  # CLI tools (aichat, mods, fabric)
    ├── repl/                 # REPL configurations
    │   ├── claude/           # Claude Code settings
    │   ├── codex/            # Codex settings
    │   ├── copilot/          # Copilot settings
    │   ├── crush/            # Crush settings
    │   ├── gemini/           # Gemini settings
    │   └── opencode/         # OpenCode settings
    ├── cloud.nix             # Cloud AI services
    ├── mcp.nix               # MCP server configurations
    └── workflows.nix         # AI workflow tools
```

## Usage

### As a Flake Input

Add this repository to your flake inputs:

```nix
{
  inputs = {
    ai-nixCfg = {
      url = "github:DivitMittal/ai-nixCfg";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
}
```

### Using Modules

Import the home-manager modules in your configuration:

```nix
{ inputs, ... }: {
  imports = [
    inputs.ai-nixCfg.homeManagerModules.default  # All modules
    # Or individual modules:
    # inputs.ai-nixCfg.homeManagerModules.claude-code
    # inputs.ai-nixCfg.homeManagerModules.codex
    # inputs.ai-nixCfg.homeManagerModules.github-copilot
  ];
}
```

### Module Options

#### Claude Code

```nix
{
  programs.claude-code.output-styles = {
    concise = ''
      ---
      name: Concise
      description: Brief, to-the-point responses
      ---

      Provide direct answers with minimal explanation.
    '';
  };
}
```

#### OpenAI Codex

```nix
{
  programs.codex = {
    enable = true;
    skills = {
      my-skill = ''
        ---
        name: my-skill
        description: A custom skill
        ---
        Instructions for the skill...
      '';
    };
    prompts = {
      explain = ''
        ---
        description: Explain code in detail
        ---
        Provide a detailed explanation...
      '';
    };
  };
}
```

#### GitHub Copilot CLI

```nix
{
  programs.github-copilot = {
    enable = true;
    mcpServers = {
      filesystem = {
        type = "local";
        command = "npx";
        args = ["-y" "@modelcontextprotocol/server-filesystem"];
      };
    };
    commands = {
      commit = ''
        ---
        allowed-tools: Bash(git add:*), Bash(git commit:*)
        description: Create a git commit
        ---
        Create an atomic commit with a descriptive message.
      '';
    };
  };
}
```

## Development

Enter the development shell:

```bash
nix develop
```

Format code:

```bash
nix fmt
```

## Related Repositories

- [DivitMittal/OS-nixCfg](https://github.com/DivitMittal/OS-nixCfg): Main Nix configurations repository

## License

MIT

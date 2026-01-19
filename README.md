<div align="center">
    <h1>ai-nixCfg</h1>
    <strong>Nix home-manager modules and personal configurations for AI coding assistants and LLM tools.</strong>
</div>

---

<div align="center">
    <a href="https://github.com/DivitMittal/ai-nixCfg/actions/workflows/flake-check.yml">
        <img src="https://github.com/DivitMittal/ai-nixCfg/actions/workflows/flake-check.yml/badge.svg" alt="nix-flake-check"/>
    </a>
    <a href="https://github.com/DivitMittal/ai-nixCfg/actions/workflows/flake-lock-update.yml">
        <img src="https://github.com/DivitMittal/ai-nixCfg/actions/workflows/flake-lock-update.yml/badge.svg" alt="flake-lock-update"/>
    </a>
</div>

---

## Overview

This repository provides reusable Nix home-manager modules and personal configurations for a comprehensive AI development toolkit. It enables declarative, reproducible setup of AI coding assistants, LLM CLI tools, and MCP (Model Context Protocol) integrations.

### Agentic Coding Assistants

| Tool | Description |
|------|-------------|
| **Claude Code** | Anthropic's AI coding assistant with MCP support |
| **OpenAI Codex** | OpenAI's code generation CLI |
| **GitHub Copilot CLI** | GitHub's AI pair programmer CLI |
| **Gemini CLI** | Google's Gemini AI coding assistant |
| **OpenCode** | Multi-provider AI coding assistant |
| **Crush** | AI coding assistant with LSP integration |

### Companion Tools

| Tool | Description |
|------|-------------|
| **ccs** | Claude Code Switcher - profile management |
| **ccusage** | Usage tracking for Claude Code |
| **ccstatusline** | Statusline integration for Claude Code |
| **ccusage-codex** | Usage tracking for Codex |
| **ccusage-opencode** | Usage tracking for OpenCode |
| **ocx** | oh-my-opencode wrapper |

### LLM CLI Tools

| Tool | Description |
|------|-------------|
| **aichat** | Multi-provider LLM client with REPL |
| **mods** | GPT-powered shell assistant |
| **fabric-ai** | Pattern-based AI workflows |

### AI Workflow Tools

| Tool | Description |
|------|-------------|
| **openspec** | Spec-driven development tool |
| **ralph-tui** | Ralph Wiggum TUI |
| **bead (bd)** | Memory system / issue tracker |
| **bv** | Beads Viewer - graph-aware task management TUI |

### AI-Powered VCS Tools

| Tool | Description |
|------|-------------|
| **geminicommit** | AI-generated git commit messages using Gemini |
| **aicommit2** | Multi-provider AI commit message generator |

### AI Cloud Platforms

| Platform | Description |
|----------|-------------|
| **Kaggle** | Data science competition platform CLI |
| **Hugging Face** | ML model hub CLI |

## Project Structure

```
.
├── flake.nix                   # Main flake entry point
├── flake/                      # Flake-parts module definitions
│   ├── actions/                # GitHub Actions workflow definitions
│   ├── checks.nix              # Pre-commit hooks
│   ├── devshells.nix           # Development shell
│   └── formatters.nix          # Code formatters (treefmt)
├── pkgs/                       # Custom package definitions
│   └── custom/
│       ├── bv-bin/             # Beads Viewer TUI binary
│       └── gowa/               # WhatsApp REST API with MCP support
├── modules/                    # Home-manager modules (reusable)
│   ├── default.nix             # Exports: claude-code, codex, github-copilot, Cfg
│   └── home/
│       ├── claude-code.nix     # Claude Code output styles
│       ├── codex.nix           # Codex skills and prompts
│       └── github-copilot.nix  # Copilot MCP servers, permissions, commands
├── config/                     # Personal configurations
│   ├── cli/                    # LLM CLI tools
│   │   ├── aichat.nix          # Multi-provider LLM client
│   │   ├── mods.nix            # GPT shell assistant
│   │   ├── fabric.nix          # Pattern-based AI workflows
│   │   └── vcs.nix             # AI-powered VCS tools
│   ├── repl/                   # Agentic coding assistants
│   │   ├── claude/             # Settings, MCP, plugins, hooks, commands, skills, agents, rules
│   │   ├── codex/              # Settings, MCP, commands, skills, rules
│   │   ├── copilot/            # Settings, MCP, commands, permissions
│   │   ├── crush/              # Settings, MCP, LSP, permissions, rules, commands
│   │   ├── gemini/             # Settings, MCP, rules, commands
│   │   └── opencode/           # Settings, MCP, LSP, memory, providers, themes, plugins
│   ├── cloud.nix               # Kaggle and Hugging Face CLI
│   ├── mcp.nix                 # Shared MCP servers (deepwiki, octocode, exa)
│   └── workflows.nix           # AI workflow tools
├── .claude/                    # Claude Code project config
└── AGENTS.md                   # AI agent instructions
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
    inputs.ai-nixCfg.homeManagerModules.claude-code
    inputs.ai-nixCfg.homeManagerModules.codex
    inputs.ai-nixCfg.homeManagerModules.github-copilot
  ];
}
```

Available modules:
- `claude-code` - Output styles management
- `codex` - Skills and prompts management
- `github-copilot` - MCP servers, settings, permissions, commands
- `Cfg` - All personal configurations (see below)

### Using Personal Configurations

To import all personal configurations from the `config/` directory, use the `Cfg` module:

```nix
{ inputs, ... }: {
  imports = [
    inputs.ai-nixCfg.homeManagerModules.Cfg
  ];
}
```

This imports the complete personal setup including:
- **Agentic REPLs**: Claude Code, Codex, GitHub Copilot CLI, Gemini, OpenCode, Crush
- **Companion Tools**: ccs, ccusage, ccstatusline, ccusage-codex, ccusage-opencode, ocx
- **LLM CLI Tools**: aichat, mods, fabric-ai
- **VCS Tools**: geminicommit, aicommit2
- **Workflow Tools**: openspec, ralph-tui, bead, bv
- **Cloud Platforms**: Kaggle, Hugging Face CLI
- **Shared MCP Servers**: deepwiki, octocode, exa, gowa

You can also import specific subsets via path:

```nix
{ inputs, ... }: {
  imports = [
    (inputs.ai-nixCfg + "/config/repl")      # Agentic coding assistants only
    (inputs.ai-nixCfg + "/config/cli")       # LLM CLI tools only
    (inputs.ai-nixCfg + "/config/cloud.nix") # Cloud platform CLIs only
    (inputs.ai-nixCfg + "/config/mcp.nix")   # Shared MCP servers only
  ];
}
```

### Module Options

#### Claude Code

Manages custom output styles in `~/.claude/output-styles/`.

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

Manages skills (`$XDG_CONFIG_HOME/codex/skills/`) and prompts (`$XDG_CONFIG_HOME/codex/prompts/`).

```nix
{
  programs.codex = {
    enable = true;
    skills = {
      skill-creator = ''
        ---
        name: skill-creator
        description: Create new skills for Codex
        ---

        You are a skill creator assistant.
        Help users create new Codex skills with proper SKILL.md format.
      '';
    };
    prompts = {
      explain = ''
        ---
        description: Explain code in detail
        argument-hint: <file-or-symbol>
        ---

        Provide a detailed explanation of the specified code.
      '';
    };
  };
}
```

#### GitHub Copilot CLI

Manages MCP servers, settings, permissions, and custom commands for GitHub Copilot CLI.

```nix
{
  programs.github-copilot = {
    enable = true;

    mcpServers = {
      filesystem = {
        type = "local";
        command = "pnpm";
        args = ["dlx" "@modelcontextprotocol/server-filesystem"];
        tools = ["*"];
      };
      deepwiki = {
        type = "http";
        url = "https://mcp.deepwiki.com/mcp";
        tools = ["*"];
      };
    };

    settings = {
      theme = "dark";
      permissions = {
        allow = ["Read" "Glob" "Grep"];
        ask = ["Edit" "Write" "Bash"];
        deny = [];
        defaultMode = "acceptEdits";
      };
    };

    commands = {
      commit = ''
        ---
        allowed-tools: Bash(git add:*), Bash(git status:*), Bash(git commit:*)
        description: Create a git commit with proper message
        ---
        ## Context

        - Current git status: !`git status`
        - Current git diff: !`git diff HEAD`
        - Recent commits: !`git log --oneline -5`

        ## Task

        Based on the changes above, create a single atomic git commit with a descriptive message.
      '';
    };
  };
}
```

### Custom Packages

This flake exports custom packages via `packages.<system>`:

```nix
{ inputs, pkgs, ... }: {
  home.packages = [
    inputs.ai-nixCfg.packages.${pkgs.system}.gowa   # WhatsApp REST API with MCP support
    inputs.ai-nixCfg.packages.${pkgs.system}.bv-bin # Beads Viewer TUI for task management
  ];
}
```

Additionally, packages from [llm-agents.nix](https://github.com/numtide/llm-agents.nix) are re-exported.

## Related Repositories

- [DivitMittal/OS-nixCfg](https://github.com/DivitMittal/OS-nixCfg): Main Nix configurations repository

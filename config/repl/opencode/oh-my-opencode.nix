{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.programs.opencode;

  ## Agents in oh-my-openagent
  agentNames = [
    "sisyphus"
    "hephaestus"
    "prometheus"
    "atlas"
    "oracle"
    "librarian"
    "explore"
    "metis"
    "momus"
    "multimodal-looker"
  ];

  ## Agent role -> model mapping per profile
  profiles = {
    ## Pure Claude via Anthropic API
    claude = {
      sisyphus = "anthropic/claude-opus-4-6";
      hephaestus = "anthropic/claude-opus-4-6";
      prometheus = "anthropic/claude-opus-4-6";
      atlas = "anthropic/claude-sonnet-4-6";
      oracle = "anthropic/claude-opus-4-6";
      librarian = "anthropic/claude-haiku-4-5";
      explore = "anthropic/claude-haiku-4-5";
      metis = "anthropic/claude-opus-4-6";
      momus = "anthropic/claude-opus-4-6";
      multimodal-looker = "anthropic/claude-sonnet-4-6";
    };

    ## OpenAI Codex models
    codex = {
      sisyphus = "openai/gpt-5.2-codex";
      hephaestus = "openai/gpt-5.2-codex";
      prometheus = "openai/gpt-5.2-codex";
      atlas = "openai/gpt-5.2-codex";
      oracle = "openai/gpt-5.2-codex";
      librarian = "openai/gpt-5.2-codex-mini";
      explore = "openai/gpt-5.2-codex-mini";
      metis = "openai/gpt-5.2-codex";
      momus = "openai/gpt-5.2-codex";
      multimodal-looker = "openai/gpt-5.2-codex";
    };

    ## Google Gemini models
    gemini = {
      sisyphus = "google/gemini-3.1-pro-preview";
      hephaestus = "google/gemini-3.1-pro-preview";
      prometheus = "google/gemini-3.1-pro-preview";
      atlas = "google/gemini-3.1-pro-preview";
      oracle = "google/gemini-3.1-pro-preview";
      librarian = "google/gemini-3-flash-preview";
      explore = "google/gemini-3-flash-preview";
      metis = "google/gemini-3.1-pro-preview";
      momus = "google/gemini-3.1-pro-preview";
      multimodal-looker = "google/gemini-3.1-pro-preview";
    };

    ## Antigravity models (Google-routed Claude/Gemini)
    agy = {
      sisyphus = "google/antigravity-claude-opus-4-6-thinking";
      hephaestus = "google/antigravity-claude-opus-4-6-thinking";
      prometheus = "google/antigravity-claude-opus-4-6-thinking";
      atlas = "google/antigravity-claude-sonnet-4-6";
      oracle = "google/antigravity-claude-opus-4-6-thinking";
      librarian = "google/antigravity-gemini-3-flash";
      explore = "google/antigravity-gemini-3-flash";
      metis = "google/antigravity-claude-opus-4-6-thinking";
      momus = "google/antigravity-claude-opus-4-6-thinking";
      multimodal-looker = "google/antigravity-gemini-3.1-pro";
    };

    ## GitHub Copilot models
    ghcp = {
      sisyphus = "github-copilot/claude-opus-4.6";
      hephaestus = "github-copilot/claude-opus-4.6";
      prometheus = "github-copilot/claude-opus-4.6";
      atlas = "github-copilot/claude-sonnet-4.6";
      oracle = "github-copilot/claude-opus-4.6";
      librarian = "github-copilot/claude-haiku-4.5";
      explore = "github-copilot/claude-haiku-4.5";
      metis = "github-copilot/claude-opus-4.6";
      momus = "github-copilot/claude-opus-4.6";
      multimodal-looker = "github-copilot/claude-sonnet-4.6";
    };

    ## Pure GLM models
    glm = {
      sisyphus = "zai-coding-plan/glm-5";
      hephaestus = "zai-coding-plan/glm-5";
      prometheus = "zai-coding-plan/glm-5";
      atlas = "zai-coding-plan/glm-4.7";
      oracle = "zai-coding-plan/glm-5";
      librarian = "zai-coding-plan/glm-4.7-flash";
      explore = "zai-coding-plan/glm-4.7-flash";
      metis = "zai-coding-plan/glm-5";
      momus = "zai-coding-plan/glm-5";
      multimodal-looker = "zai-coding-plan/glm-4.7";
    };

    ## OpenRouter free models
    openrouter = {
      sisyphus = "openrouter/moonshotai/kimi-k2:free";
      hephaestus = "openrouter/moonshotai/kimi-k2:free";
      prometheus = "openrouter/moonshotai/kimi-k2:free";
      atlas = "openrouter/moonshotai/kimi-k2:free";
      oracle = "openrouter/moonshotai/kimi-k2:free";
      librarian = "openrouter/moonshotai/kimi-k2:free";
      explore = "openrouter/moonshotai/kimi-k2:free";
      metis = "openrouter/moonshotai/kimi-k2:free";
      momus = "openrouter/moonshotai/kimi-k2:free";
      multimodal-looker = "openrouter/moonshotai/kimi-k2:free";
    };

    ## Zen profile (OpenCode free models)
    zen = {
      sisyphus = "opencode/big-pickle";
      hephaestus = "opencode/big-pickle";
      prometheus = "opencode/big-pickle";
      atlas = "opencode/gpt-5-nano";
      oracle = "opencode/big-pickle";
      librarian = "opencode/gpt-5-nano";
      explore = "opencode/gpt-5-nano";
      metis = "opencode/big-pickle";
      momus = "opencode/big-pickle";
      multimodal-looker = "opencode/gpt-5-nano";
    };
  };

  ## oh-my-opencode base config (shared across profiles)
  ohMyOpencodeBase = {
    "$schema" = "https://raw.githubusercontent.com/code-yeongyu/oh-my-openagent/dev/assets/oh-my-opencode.schema.json";
    google_auth = false; ## Using Antigravity auth instead
    disabled_hooks = ["session-notification" "ralph-loop"];
    ralph_loop = {
      enabled = false;
    };
    claude_code = {
      mcp = false;
      commands = true;
      skills = true;
      agents = true;
      hooks = true;
      plugins = true;
    };
  };

  ## ocx.jsonc base config
  ghostConfig = {
    registries = {};
    componentPath = ".opencode";
  };

  ## Generate oh-my-opencode.jsonc for a profile
  mkOhMyOpencodeConfig = _profileName: agentModels:
    ohMyOpencodeBase
    // {
      agents = lib.genAttrs agentNames (agent: {
        model = agentModels.${agent};
      });
    };

  ## Generate profile directory contents
  mkProfileFiles = profileName: agentModels: let
    ohMyConfig = mkOhMyOpencodeConfig profileName agentModels;
  in {
    "opencode/profiles/${profileName}/oh-my-opencode.jsonc" = {
      inherit (cfg) enable;
      text = builtins.toJSON ohMyConfig;
    };
    "opencode/profiles/${profileName}/ocx.jsonc" = {
      inherit (cfg) enable;
      text = builtins.toJSON ghostConfig;
    };
  };

  ## Generate all profile files
  allProfileFiles =
    lib.foldl' (acc: profileName:
      acc // (mkProfileFiles profileName profiles.${profileName})) {} (lib.attrNames profiles);
in {
  ## Profile switching is handled by ocx (pnpm dlx ocx)
  xdg.configFile = mkIf cfg.enable allProfileFiles;
  home.packages = lib.mkIf cfg.enable (lib.attrsets.attrValues {
    ocx = pkgs.writeShellScriptBin "ocx" ''
      exec ${pkgs.pnpm}/bin/pnpm dlx ocx "$@"
    '';
  });
}

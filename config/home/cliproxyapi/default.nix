{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types literalExpression;

  # Reads an API key from a runtime-managed env var. We intentionally do NOT
  # commit provider secrets to the repo; populate these at activation time via
  # shell env or your secret manager. The first activation leaves these blank
  # (so the proxy still starts and serves OAuth-backed routes) and you fill
  # them in via the dashboard at http://localhost:8317 once running.
in {
  options.programs.cliproxyapi.settings = mkOption {
    type = types.attrs;
    default = {
      port = 8317;
      debug = false;
      logging-to-file = false;
      request-log = false;
      usage-statistics-enabled = true;
      auth-dir = "${config.xdg.configHome}/cliproxyapi/auth";
      api-keys = ["ccs-internal-managed"];

      # Mirror OAuth routing behavior from the previous CCS-managed config so
      # multi-account rotation works without intervention.
      quota-exceeded = {
        switch-project = true;
        switch-preview-model = true;
      };
      routing = {
        strategy = "round-robin";
        session-affinity = false;
        session-affinity-ttl = "1h";
      };

      # API-key providers (OpenAI Chat Completions compatible). The proxy
      # itself acts as an Anthropic- and OpenAI-compatible frontend so all
      # five harnesses (claude-code, codex, opencode, forgecode, jcode) can
      # reach these providers without per-harness provider config.
      #
      # `api-key-entries` are intentionally empty by default so secrets stay
      # out of the Nix store. Add keys at runtime via:
      #   curl -X PATCH http://localhost:8317/v0/management/...
      # or by editing the mutable config.yaml directly after first activation.
      openai-compatibility = [
        {
          name = "z-ai";
          base-url = "https://api.z.ai/v1";
          api-key-entries = [];
          models = [
            {
              name = "glm-4.5";
              alias = "glm-4.5";
            }
            {
              name = "glm-4.6";
              alias = "glm-4.6";
            }
          ];
        }
        {
          name = "minimax";
          base-url = "https://api.minimax.io/v1";
          api-key-entries = [];
          models = [
            {
              name = "MiniMax-M3";
              alias = "minimax-M3";
            }
          ];
        }
        {
          name = "openrouter";
          base-url = "https://openrouter.ai/api/v1";
          api-key-entries = [];
          models = [];
        }
      ];
    };
    defaultText = literalExpression ''
      {
        port = 8317;
        auth-dir = "$\{config.xdg.configHome}/cliproxyapi/auth";
        # See ./default.nix for full default
      }
    '';
    description = ''
      Declarative CLIProxyAPI settings. See
      {file}`config/home/cliproxyapi/default.nix` for the full default shape.
      Override sparingly — most provider-specific tweaks belong in the
      dashboard once the proxy is running.
    '';
  };

  config = {
    programs.cliproxyapi = {
      enable = true;
      inheritLegacyAuth = true;
      mutableUserSettings = true;
    };

    # Export OpenAI-compatible env vars so any client that honors them
    # (codex, opencode, jcode, forgecode, etc.) routes through the local
    # proxy by default. Anthropic-format clients (claude-code) use
    # programs.claude-code.settings.env instead.
    home.sessionVariables = lib.mkIf config.programs.cliproxyapi.enable {
      OPENAI_BASE_URL = "http://127.0.0.1:8317/v1";
      OPENAI_API_KEY = "ccs-internal-managed";
    };
  };
}

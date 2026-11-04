{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.cliproxyapi;
  baseUrl = cfg.endpoint;
  apiKeyEnv = "OPENAI_API_KEY";
  apiKey = lib.head cfg.settings.api-keys;
  defaultModel = "gpt-5.6-sol";

  piModels = (pkgs.formats.json {}).generate "pi-models.json" {
    providers.cliproxy = {
      baseUrl = "${baseUrl}/v1";
      api = "openai-completions";
      inherit apiKey;
      models = map (id: {inherit id;}) [
        defaultModel
        "gpt-6-astra"
        "claude-sonnet-4-6"
        "gemini-3-flash"
      ];
    };
  };
in {
  ## Harnesses that ignore OPENAI_BASE_URL and need their own wiring. Cursor and
  ## Antigravity talk to their vendor backends only and have no base-URL
  ## override to set.
  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.clients.openai) {
      home.sessionVariables = {
        ## goose reads OPENAI_HOST and appends its own /v1/chat/completions.
        OPENAI_HOST = baseUrl;
        JCODE_OPENAI_COMPAT_API_BASE = "${baseUrl}/v1";
        JCODE_OPENAI_COMPAT_API_KEY_NAME = apiKeyEnv;
        JCODE_OPENAI_COMPAT_DEFAULT_MODEL = defaultModel;
      };

      ## pi-rust shares ~/.pi/agent/models.json with the TypeScript Pi.
      programs.pi.coding-agent.models = piModels;

      xdg.configFile."zerostack/config.toml".source = (pkgs.formats.toml {}).generate "zerostack-config.toml" {
        provider = "cliproxy";
        model = defaultModel;
        custom_providers.cliproxy = {
          provider_type = "openai";
          base_url = "${baseUrl}/v1";
          api_key_env = apiKeyEnv;
          api_style = "completions";
        };
      };

      ## Hermes' custom provider ignores OPENAI_API_KEY.
      programs.hermes-agent.settings.model = {
        provider = "custom";
        base_url = "${baseUrl}/v1";
        api_key = apiKey;
        default = defaultModel;
      };
    })

    ## Only the Antigravity-owned Claude IDs serve /v1/messages; the proxy's
    ## Copilot-owned ones (including every Haiku) return 400/503, so each tier
    ## has to be pinned or Claude Code's background calls fail.
    (lib.mkIf (cfg.enable && cfg.clients.claudeCode) {
      programs.claude-code.settings.env = {
        ANTHROPIC_DEFAULT_OPUS_MODEL = "claude-opus-4-6-thinking";
        ANTHROPIC_DEFAULT_SONNET_MODEL = "claude-sonnet-4-6";
        ANTHROPIC_DEFAULT_HAIKU_MODEL = "claude-sonnet-4-6";
      };
    })
  ];
}

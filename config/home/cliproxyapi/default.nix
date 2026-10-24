{config, ...}: {
  config = {
    programs.cliproxyapi = {
      enable = true;
      mutableUserSettings = true;

      # Codex/opencode/jcode/forgecode reach every provider through the proxy.
      # Claude Code keeps its own Anthropic login: no claude account is wired
      # into the proxy, so routing it there would serve Claude models from
      # other providers' accounts.
      clients.openai = true;

      settings = {
        port = 8317;
        debug = false;
        logging-to-file = false;
        request-log = false;
        usage-statistics-enabled = true;
        auth-dir = "${config.xdg.configHome}/cliproxyapi/auth";
        api-keys = ["cliproxyapi-local"];

        # Rotate across OAuth accounts and fall back to other projects/preview
        # models on quota errors, so multi-account setups need no intervention.
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
        # `api-key-entries` are deliberately left out so secrets stay out of the
        # Nix store; the activation merge keys providers by `name`, so entries
        # added at runtime survive re-activation. Fill them in via the
        # dashboard at http://localhost:8317 once running, or at runtime via:
        #   curl -X PATCH http://localhost:8317/v0/management/...
        # or by editing the mutable config.yaml directly after first activation.
        openai-compatibility = [
          {
            name = "z-ai";
            base-url = "https://api.z.ai/api/paas/v4";
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
            models = [];
          }
        ];
      };
    };
  };
}

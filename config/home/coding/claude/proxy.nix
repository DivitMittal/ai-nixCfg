{
  config,
  lib,
  ...
}: {
  # Point Claude Code at the local CLIProxyAPI(Plus) instance, which fronts
  # both OAuth-backed providers (gemini, codex, agy, qwen, kiro, ghcp, kimi,
  # cursor, etc.) and custom OpenAI-compatible providers (z-ai, minimax,
  # openrouter). All model routes are picked server-side based on the model
  # name; the proxy returns Anthropic-format responses so Claude Code is
  # none-the-wiser.
  programs.claude-code.settings.env = lib.mkIf config.programs.cliproxyapi.enable {
    ANTHROPIC_BASE_URL = "http://127.0.0.1:8317";
    ANTHROPIC_AUTH_TOKEN = "ccs-internal-managed";
  };
}
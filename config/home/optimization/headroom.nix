{
  pkgs,
  customLib,
  ...
}: let
  headroomBin = customLib.mkUvxBin pkgs "headroom" "--from headroom-ai[all] headroom";
  cogneeMcpBin = customLib.mkUvxBin pkgs "cognee-mcp" "--from cognee-mcp cognee-mcp";
in {
  home.packages = [headroomBin cogneeMcpBin];

  # Session-wide headroom defaults; override per-session via env before calling headroom proxy.
  home.sessionVariables = {
    HEADROOM_PORT = "8787";
    HEADROOM_HOST = "127.0.0.1";
    HEADROOM_MODE = "token";
    HEADROOM_TELEMETRY = "off";
    HEADROOM_OUTPUT_SHAPER = "1";
    HEADROOM_CONTEXT_TOOL = "rtk";
    HEADROOM_UPDATE_CHECK = "off";
  };

  # hr-<agent> = start the proxy + wrap the agent in a single command.
  # headroom wrap handles ANTHROPIC_BASE_URL / provider wiring per-session,
  # never mutating the declarative config files this repo manages.
  programs.fish.shellAliases = {
    hr-claude = "headroom wrap claude";
    hr-codex = "headroom wrap codex";
    hr-opencode = "headroom wrap opencode";
    hr-copilot = "headroom wrap copilot";
    hr-openclaw = "headroom wrap openclaw";
    # Run just the proxy (useful as a background service substitute)
    hr-proxy = "headroom proxy --port 8787";
    hr-learn = "headroom learn --apply";
    hr-stats = "headroom perf";
    hr-check = "headroom doctor";
  };
}

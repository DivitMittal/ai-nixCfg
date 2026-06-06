{
  config,
  lib,
  ...
}: let
  inherit (lib) mkOption types mkIf;
  cfg = config.programs.openclaw;

  # Default workspace path — must match programs.openclaw.workspaceDir if overridden
  # via the upstream nix-openclaw module.
  defaultWorkspaceDir = "${config.home.homeDirectory}/.openclaw/workspace";
in {
  # Extension module — adds declarative workspace file management on top of
  # the upstream nix-openclaw homeManagerModules.openclaw module.
  options.programs.openclaw = {
    extraBootstrapFiles = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = lib.literalExpression ''
        {
          "AGENTS.md" = '''
            # AI Agent Guidelines
            Follow the project conventions at all times.
          ''';
          "SOUL.md" = '''
            You are a helpful, precise assistant.
          ''';
        }
      '';
      description = ''
        Extra workspace bootstrap files for OpenClaw, written to
        {file}`~/.openclaw/workspace/` (the upstream default workspace directory).

        Each attribute name is a filename and the value is its text content.
        If you configure a custom workspace directory via the upstream nix-openclaw
        {option}`programs.openclaw.workspaceDir`, set
        {option}`programs.openclaw.extraBootstrapWorkspaceDir` to match.
      '';
    };

    extraBootstrapWorkspaceDir = mkOption {
      type = types.str;
      default = defaultWorkspaceDir;
      defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/.openclaw/workspace"'';
      description = ''
        Target directory for {option}`programs.openclaw.extraBootstrapFiles`.
        Override this when using a custom {option}`programs.openclaw.workspaceDir`
        via the upstream nix-openclaw module.
      '';
    };
  };

  config = mkIf (cfg.extraBootstrapFiles != {}) {
    home.file =
      lib.mapAttrs' (
        name: text:
          lib.nameValuePair "${cfg.extraBootstrapWorkspaceDir}/${name}" {inherit text;}
      )
      cfg.extraBootstrapFiles;
  };
}

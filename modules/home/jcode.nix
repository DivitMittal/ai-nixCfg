{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.programs.jcode;
  tomlFormat = pkgs.formats.toml {};
  settingsFile = tomlFormat.generate "jcode-settings.toml" cfg.settings;
  python = pkgs.python3.withPackages (ps: [ps.tomlkit]);
in {
  options.programs.jcode = {
    enable = lib.mkEnableOption "Jcode coding assistant";

    package = lib.mkPackageOption pkgs "jcode" {};

    settings = lib.mkOption {
      inherit (tomlFormat) type;
      default = {};
      description = ''
        Non-secret Jcode settings merged into ~/.jcode/config.toml at activation.
        Declared values take precedence over local settings on each activation.
        Undeclared settings remain writable and are preserved.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    # Jcode saves settings such as the selected default model in this same file.
    # A Nix store symlink would break those in-app writes.
    home.activation.applyJcodeSettings = lib.mkIf (cfg.settings != {}) (lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${lib.getExe python} ${./jcode/merge-settings.py} ${settingsFile} \
        ${lib.escapeShellArg "${config.home.homeDirectory}/.jcode/config.toml"}
    '');
  };
}

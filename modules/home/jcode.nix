# Declarative Jcode settings merged at activation.
#
# Non-secret settings (provider config, models, UI prefs) are declared here.
# API keys are injected from ${JCODE_HOME}/secrets/ at runtime, never in git.
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
  jcodeHome = config.home.sessionVariables.JCODE_HOME or "${config.home.homeDirectory}/.jcode";
  secretsDir = "${jcodeHome}/secrets";
in {
  options.programs.jcode = {
    enable = lib.mkEnableOption "Jcode coding assistant";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The jcode package to use.";
    };

    settings = lib.mkOption {
      inherit (tomlFormat) type;
      default = {};
      description = ''
        Non-secret Jcode settings merged into config.toml at activation
        (under JCODE_HOME, or ~/.jcode when that is unset).
        Declared values take precedence over local settings on each activation.
        Undeclared settings remain writable and are preserved.
      '';
    };

    providerSettings = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      example = { lappkart = "JCODE_PROVIDER_LAPPKART_API_KEY"; };
      description = ''
        Provider API key environment variable names mapped to secret file
        names under ${secretsDir}. At activation, each secret file is
        created (mode 600) if it does not already contain a value, so
        first-setup keys persist across rebuilds without being in git.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [cfg.package];

    # Ensure the secrets directory exists for runtime key injection.
    home.activation.jcodeSecretsDir = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${pkgs.coreutils}/bin/mkdir -p -m 700 ${lib.escapeShellArg secretsDir}
    '';

    # Write provider API key env files from secrets directory.
    # If the secret file already has content, preserve it; otherwise create
    # an empty placeholder so the user knows which variable to set.
    home.activation.writeJcodeProviderSecrets = lib.mkIf (cfg.providerSettings != {}) (lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (envVar: secretName: ''
        ${pkgs.coreutils}/bin/install -m 600 /dev/null ${lib.escapeShellArg "${secretsDir}/${secretName}"}
        if [ -s ${lib.escapeShellArg "${secretsDir}/${secretName}"} ]; then
          echo "jcode: preserved secret ${secretName}"
        else
          echo "jcode: set ${envVar} in ${secretsDir}/${secretName}"
        fi
      '') cfg.providerSettings)}
    '');

    # Merge declarative settings into config.toml without freezing writable state.
    home.activation.applyJcodeSettings = lib.mkIf (cfg.settings != {}) (lib.hm.dag.entryAfter ["writeBoundary"] ''
      run ${lib.getExe python} ${./merge-settings.py} ${settingsFile} \
        ${lib.escapeShellArg "${jcodeHome}/config.toml"}
    '');
  };
}

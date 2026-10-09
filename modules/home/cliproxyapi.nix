{
  config,
  lib,
  pkgs,
  ai-nixCfg,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types literalExpression;
  cfg = config.programs.cliproxyapi;

  yamlFormat = pkgs.formats.yaml {};
  configMerger = pkgs.python3.withPackages (ps: [ps.pyyaml]);

  # Auth tokens and OAuth credentials live under a separate XDG subdir so that
  # they can survive config-file regeneration, be marked mutable, and never be
  # written into the Nix store.
  defaultAuthDir = "${config.xdg.configHome}/cliproxyapi/auth";
  defaultDataDir = "${config.xdg.dataHome}/cliproxyapi";
  defaultConfigDir = "${config.xdg.configHome}/cliproxyapi";

  configPath = "${defaultConfigDir}/config.yaml";
  staticSettings = yamlFormat.generate "cliproxyapi-config" cfg.settings;
  hasSettings = cfg.settings != {};

  # Preserve an existing CCS-style auth dir on first activation so that all
  # currently logged-in OAuth accounts carry over without re-authentication.
  legacySymlinkActivation = ''
    target=${lib.escapeShellArg defaultAuthDir}
    legacy=${lib.escapeShellArg "${config.home.homeDirectory}/.ccs/cliproxy/auth"}
    if [ -d "$legacy" ] && [ ! -e "$target" ]; then
      mkdir -p "$(dirname "$target")"
      ln -s "$legacy" "$target"
    fi
  '';

  mutableConfigMerger = ''
    ${configMerger}/bin/python - ${lib.escapeShellArg configPath} ${lib.escapeShellArg staticSettings} <<'PY'
    import pathlib
    import sys

    import yaml


    def read_yaml(path: pathlib.Path) -> dict:
        if not path.exists():
            return {}
        content = path.read_text()
        if not content.strip():
            return {}
        data = yaml.safe_load(content)
        return data if isinstance(data, dict) else {}


    def merge(dynamic: dict, static: dict) -> dict:
        result = dict(dynamic)
        for key, value in static.items():
            if isinstance(value, dict) and isinstance(result.get(key), dict):
                result[key] = merge(result[key], value)
            else:
                result[key] = value
        return result


    config_path = pathlib.Path(sys.argv[1])
    static_path = pathlib.Path(sys.argv[2])

    config_path.parent.mkdir(parents=True, exist_ok=True)
    dynamic = read_yaml(config_path)
    static = read_yaml(static_path)

    config_path.write_text(yaml.safe_dump(merge(dynamic, static), sort_keys=False))
    PY
  '';
in {
  options.programs.cliproxyapi = {
    enable = mkEnableOption "CLIProxyAPI(Plus) local proxy";

    package = mkOption {
      type = types.nullOr types.package;
      default = ai-nixCfg.packages.${pkgs.stdenvNoCC.hostPlatform.system}.cliproxyapi-plus or null;
      defaultText = literalExpression ''
        `ai-nixCfg.packages.\${pkgs.stdenvNoCC.hostPlatform.system}.cliproxyapi-plus`
      '';
      description = ''
        Package providing the {command}`cli-proxy-api-plus` executable. Defaults
        to the Nix-packaged upstream build; override to pin a specific release.
      '';
    };

    mutableUserSettings = mkOption {
      type = types.bool;
      default = true;
      example = false;
      description = ''
        Whether CLIProxyAPI can mutate its configuration at runtime.

        When enabled (default), Home Manager deep-merges declarative settings
        into a real mutable {file}`config.yaml` during activation. This lets
        runtime state — dashboard-injected provider entries, OAuth model alias
        edits, secret rotations — remain mutable and unmanaged by Nix.

        When disabled, the entire config file is replaced by a Nix-store
        symlink, so any runtime edits are wiped on activation.
      '';
    };

    inheritLegacyAuth = mkOption {
      type = types.bool;
      default = true;
      description = ''
        On first activation, if a legacy {file}`~/.ccs/cliproxy/auth` directory
        exists and no {file}`auth` directory exists at the new location,
        symlink the new path to the legacy one so existing OAuth credentials
        carry over without re-authentication.
      '';
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      example = literalExpression ''
        {
          port = 8317;
          auth-dir = "\${config.xdg.configHome}/cliproxyapi/auth";
          api-keys = ["my-static-key"];
          openai-compatibility = [
            {
              name = "openrouter";
              base-url = "https://openrouter.ai/api/v1";
              api-key-entries = [{api-key = "sk-or-v1-...";}];
              models = [{name = "moonshotai/kimi-k2:free"; alias = "kimi-k2";}];
            }
          ];
        }
      '';
      description = ''
        Declarative CLIProxyAPI(Plus) settings written to {file}`config.yaml`.

        In mutable mode these settings are deep-merged into the existing file;
        runtime-managed fields (OAuth account state, dashboard-injected
        entries, secret rotations) are preserved. In immutable mode the entire
        file is replaced.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = lib.optional (cfg.package != null) cfg.package;

    home.activation = lib.mkMerge [
      (mkIf cfg.inheritLegacyAuth {
        cliproxyapiInheritLegacyAuth = lib.hm.dag.entryAfter ["linkGeneration"] legacySymlinkActivation;
      })
      (mkIf (cfg.mutableUserSettings && hasSettings) {
        cliproxyapiSettingsActivation =
          lib.hm.dag.entryAfter (
            ["linkGeneration"]
            ++ lib.optional cfg.inheritLegacyAuth "cliproxyapiInheritLegacyAuth"
          )
          mutableConfigMerger;
      })
      ## Make sure the auth dir exists so the binary can write to it on first run.
      {
        cliproxyapiDataDirs = lib.hm.dag.entryAfter ["linkGeneration"] ''
          ${pkgs.coreutils}/bin/mkdir -p ${lib.escapeShellArg defaultAuthDir} ${lib.escapeShellArg defaultDataDir}
        '';
      }
    ];

    home.file.".config/cliproxyapi/config.yaml" = mkIf (!cfg.mutableUserSettings && hasSettings) {
      source = staticSettings;
    };
  };
}

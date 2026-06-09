{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types literalExpression;
  cfg = config.programs.claude-code;
  ccsCfg = config.programs.ccs;

  yamlFormat = pkgs.formats.yaml {};
  ccsConfigMerger = pkgs.python3.withPackages (ps: [ps.pyyaml]);

  ccsConfigDirPath =
    if ccsCfg.useXdgConfigHome
    then "${config.xdg.configHome}/ccs"
    else "${config.home.homeDirectory}/.ccs";
  ccsLegacyConfigDirPath = "${config.home.homeDirectory}/.ccs";
  ccsConfigPath = "${ccsConfigDirPath}/config.yaml";

  ccsRelativeConfigDir =
    if ccsCfg.useXdgConfigHome
    then "${lib.removePrefix "${config.home.homeDirectory}/" config.xdg.configHome}/ccs"
    else ".ccs";

  ccsStaticSettings = yamlFormat.generate "ccs-config" ccsCfg.settings;

  ccsHasSettings = ccsCfg.settings != {};

  ccsPreserveLegacyFilesActivation = ''
    target_dir=${lib.escapeShellArg ccsConfigDirPath}
    legacy_dir=${lib.escapeShellArg ccsLegacyConfigDirPath}

    if [ "$target_dir" != "$legacy_dir" ] && [ -d "$legacy_dir" ]; then
      mkdir -p "$target_dir"

      for rel in ${lib.escapeShellArgs ccsCfg.preservedLegacyPaths}; do
        legacy_path="$legacy_dir/$rel"
        target_path="$target_dir/$rel"

        if [ -e "$legacy_path" ] && [ ! -e "$target_path" ] && [ ! -L "$target_path" ]; then
          mkdir -p "$(dirname "$target_path")"
          ln -s "$legacy_path" "$target_path"
        fi
      done
    fi
  '';

  ccsMutableConfigMerger = ''
    ${ccsConfigMerger}/bin/python - ${lib.escapeShellArg ccsConfigPath} ${lib.escapeShellArg ccsStaticSettings} <<'PY'
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
  options = {
    programs.ccs = {
      enable = mkEnableOption "Claude Code Switcher";

      package = mkOption {
        type = types.nullOr types.package;
        default = null;
        description = ''
          Package providing the {command}`ccs` executable.

          Set to null to manage only configuration and environment variables.
        '';
      };

      useXdgConfigHome = mkOption {
        type = types.bool;
        default = config.home.preferXdgDirectories;
        defaultText = literalExpression "config.home.preferXdgDirectories";
        description = ''
          Whether to place the CCS configuration directory under
          {file}`$XDG_CONFIG_HOME/ccs` by setting {env}`CCS_DIR`.

          CCS does not currently read {env}`XDG_CONFIG_HOME` directly; it supports
          relocation through {env}`CCS_DIR`.
        '';
      };

      mutableUserSettings = mkOption {
        type = types.bool;
        default = false;
        example = true;
        description = ''
          Whether CCS can mutate its configuration at runtime.

          When enabled, Home Manager deep-merges declarative settings into a real
          mutable {file}`config.yaml` during activation instead of replacing the
          entire file with a Nix store-backed symlink. Runtime state and secrets
          not declared in Home Manager are preserved.
        '';
      };

      preserveLegacyFiles = mkOption {
        type = types.bool;
        default = true;
        example = false;
        description = ''
          When using {env}`CCS_DIR` outside {file}`~/.ccs`, create symlinks from
          the new directory back to existing legacy CCS files. This starts from an
          existing {file}`~/.ccs` setup while leaving OAuth tokens and other
          secrets in place.
        '';
      };

      preservedLegacyPaths = mkOption {
        type = types.listOf types.str;
        default = [
          "config.yaml"
          ".session-secret"
          "cliproxy/accounts.json"
          "cliproxy/auth"
          "cliproxy/auth-paused"
        ];
        example = literalExpression ''
          [
            "config.yaml"
            "glm.settings.json"
            "cliproxy/accounts.json"
            "cliproxy/auth"
          ]
        '';
        description = ''
          Relative paths under {file}`~/.ccs` to expose in the relocated CCS
          directory as symlinks when {option}`programs.ccs.preserveLegacyFiles`
          is enabled. Existing files in the target directory are never replaced.
        '';
      };

      settings = mkOption {
        type = types.attrsOf types.anything;
        default = {};
        example = literalExpression ''
          {
            preferences.theme = "dark";
            logging = {
              enabled = true;
              level = "info";
            };
          }
        '';
        description = ''
          Declarative CCS settings written to {file}`config.yaml`.

          In mutable mode these settings are deep-merged into the existing file,
          allowing CCS-managed OAuth tokens, API keys, and runtime state to remain
          mutable and unmanaged by Nix.
        '';
      };
    };

    programs.claude-code = {
      output-styles = mkOption {
        type = types.attrsOf types.str;
        default = {};
        example = lib.literalExpression ''
          {
            concise = '''
              ---
              name: Concise
              description: Brief, to-the-point responses
              ---

              Provide direct answers with minimal explanation.
            ''';
          }
        '';
        description = ''
          Custom output styles for claude-code.

          Each attribute defines a custom output style as a markdown file with frontmatter.
          Files will be written to {file}`.claude/output-styles/`.

          See <https://code.claude.com/docs/en/output-styles> for more information.
        '';
      };
    };
  };

  config = lib.mkMerge [
    (mkIf ccsCfg.enable {
      home.packages = lib.optional (ccsCfg.package != null) ccsCfg.package;

      home.sessionVariables = lib.mkIf ccsCfg.useXdgConfigHome {
        CCS_DIR = ccsConfigDirPath;
      };

      home.activation = lib.mkMerge [
        (lib.mkIf (ccsCfg.preserveLegacyFiles && ccsCfg.useXdgConfigHome) {
          ccsPreserveLegacyFiles = lib.hm.dag.entryAfter ["linkGeneration"] ccsPreserveLegacyFilesActivation;
        })
        (lib.mkIf (ccsCfg.mutableUserSettings && ccsHasSettings) {
          ccsSettingsActivation = lib.hm.dag.entryAfter (["linkGeneration"] ++ lib.optional (ccsCfg.preserveLegacyFiles && ccsCfg.useXdgConfigHome) "ccsPreserveLegacyFiles") ccsMutableConfigMerger;
        })
      ];

      home.file."${ccsRelativeConfigDir}/config.yaml" = lib.mkIf (!ccsCfg.mutableUserSettings && ccsHasSettings) {
        source = ccsStaticSettings;
      };
    })

    (mkIf (cfg.output-styles != {}) {
      home.file = lib.mapAttrs' (name: content:
        lib.nameValuePair ".claude/output-styles/${name}.md" {
          text = content;
        })
      cfg.output-styles;
    })
  ];
}

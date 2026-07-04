{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types literalExpression;
  cfg = config.programs.codex;

  tomlFormat = pkgs.formats.toml {};
  codexConfigMerger = pkgs.python3.withPackages (ps: [ps."tomli-w"]);

  packageVersion =
    if cfg.package != null
    then lib.getVersion cfg.package
    else "0.94.0";
  isTomlConfig = lib.versionAtLeast packageVersion "0.2.0";

  useXdgDirectories = config.home.preferXdgDirectories && isTomlConfig;
  xdgConfigHome = lib.removePrefix config.home.homeDirectory config.xdg.configHome;
  configDir =
    if useXdgDirectories
    then "${xdgConfigHome}/codex"
    else ".codex";
  configFileName =
    if isTomlConfig
    then "config.toml"
    else "config.yaml";
  configPath =
    if useXdgDirectories
    then "${config.xdg.configHome}/codex/${configFileName}"
    else "${config.home.homeDirectory}/.codex/${configFileName}";

  transformedMcpServers = lib.optionalAttrs (cfg.enableMcpIntegration && config.programs.mcp.enable) (
    lib.mapAttrs (
      _name: server:
        (lib.removeAttrs server [
          "disabled"
          "headers"
        ])
        // (lib.optionalAttrs (server ? headers && !(server ? http_headers)) {
          http_headers = server.headers;
        })
        // {
          enabled = !(server.disabled or false);
        }
    )
    config.programs.mcp.servers
  );

  settings =
    if cfg.settings == null
    then {}
    else cfg.settings;
  settingMcpServers = lib.attrByPath ["mcp_servers"] {} settings;
  mergedMcpServers = lib.filterAttrs (_: server: server != null) (
    lib.mapAttrs (_: server: lib.filterAttrsRecursive (_: value: value != null) server) (
      transformedMcpServers // settingMcpServers
    )
  );
  mergedSettings =
    settings // lib.optionalAttrs (mergedMcpServers != {}) {mcp_servers = mergedMcpServers;};

  staticSettings = tomlFormat.generate "codex-config" mergedSettings;

  mutableConfigMerger = ''
    ${codexConfigMerger}/bin/python - ${lib.escapeShellArg configPath} ${lib.escapeShellArg staticSettings} <<'PY'
    import pathlib
    import sys
    import tomllib

    import tomli_w


    def read_toml(path: pathlib.Path) -> dict:
        if not path.exists():
            return {}
        content = path.read_bytes()
        if not content.strip():
            return {}
        return tomllib.loads(content.decode())


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
    dynamic = read_toml(config_path)
    static = read_toml(static_path)

    if config_path.is_symlink():
        config_path.unlink()

    config_path.write_text(tomli_w.dumps(merge(dynamic, static)))
    PY
  '';
in {
  options.programs.codex = {
    mutableUserSettings = mkOption {
      type = types.bool;
      default = false;
      example = true;
      description = ''
        Whether user settings ({file}`config.toml`) can be updated by Codex.

        When enabled, Home Manager writes the declarative settings into a real
        mutable {file}`CODEX_HOME/config.toml` during activation instead of
        leaving the file as a Nix store-backed symlink. This allows Codex to
        persist runtime state such as project trust decisions.
      '';
    };

    prompts = mkOption {
      type = types.attrsOf types.str;
      default = {};
      example = literalExpression ''
        {
          explain = '''
            ---
            description: Explain code in detail
            argument-hint: <file-or-symbol>
            ---

            Provide a detailed explanation of the specified code.
          ''';
        }
      '';
      description = ''
        Custom prompts for Codex CLI.

        Each attribute defines a custom prompt. The attribute name becomes the prompt filename,
        and the value is the prompt content with optional YAML frontmatter.
        Prompts are stored in {file}`$XDG_CONFIG_HOME/codex/prompts/<name>.md`.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.activation = lib.mkIf (cfg.mutableUserSettings && isTomlConfig && mergedSettings != {}) {
      codexSettingsActivation = lib.hm.dag.entryAfter ["linkGeneration"] mutableConfigMerger;
    };

    home.file."${configDir}/${configFileName}".enable =
      lib.mkIf (cfg.mutableUserSettings && isTomlConfig && mergedSettings != {}) (lib.mkForce false);

    xdg.configFile = lib.mkMerge [
      # Prompts: each prompt is a markdown file (Slash Commands)
      (lib.mapAttrs' (name: content:
        lib.nameValuePair "codex/prompts/${name}.md" {
          text = content;
        })
      cfg.prompts)
    ];
  };
}

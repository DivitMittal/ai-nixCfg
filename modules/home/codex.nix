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

  # Empty defaults from programs.mcp (args = [], env = {}, ...) must be dropped:
  # Codex rejects `args`/`env` on streamable_http servers even when empty.
  transformedMcpServers = lib.optionalAttrs (cfg.enableMcpIntegration && config.programs.mcp.enable) (
    lib.mapAttrs (
      _name: server:
        lib.filterAttrs (_: value: value != null && value != [] && value != {}) (
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

  petType = types.submodule ({name, ...}: {
    options = {
      spritesheet = mkOption {
        type = types.path;
        description = "PNG or WebP sprite sheet in the 1536×1872 v1 or 1536×2288 v2 layout.";
      };
      displayName = mkOption {
        type = types.str;
        default = name;
        description = "Name shown in the terminal pet picker.";
      };
      description = mkOption {
        type = types.str;
        default = "";
        description = "Description shown in the terminal pet picker.";
      };
    };
  });

  mkPet = name: pet: let
    manifest = (pkgs.formats.json {}).generate "${name}-pet.json" {
      id = name;
      inherit (pet) displayName description;
      spritesheetPath = "spritesheet.png";
    };
  in
    pkgs.runCommand "codex-pet-${name}" {nativeBuildInputs = [pkgs.imagemagick];} ''
      dimensions=$(magick identify -format '%wx%h' ${lib.escapeShellArg "${pet.spritesheet}"})
      case "$dimensions" in
        1536x1872|1536x2288) ;;
        *) echo "Codex pet ${name}: expected 1536x1872 or 1536x2288, got $dimensions" >&2; exit 1 ;;
      esac
      mkdir -p "$out"
      # The CLI accepts nine animation rows; v2 adds two desktop look-direction rows.
      magick ${lib.escapeShellArg "${pet.spritesheet}"} -crop 1536x1872+0+0 +repage "$out/spritesheet.png"
      cp ${manifest} "$out/pet.json"
    '';

  mutableConfigMerger = ''
    ${codexConfigMerger}/bin/python - ${lib.escapeShellArg configPath} ${lib.escapeShellArg staticSettings} <<'PY'
    import json
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

    merged = merge(dynamic, static)

    # Declared MCP servers replace their live tables wholesale so keys removed
    # from Nix (e.g. a stale `args = []`) don't linger, and servers declared by a
    # previous generation but dropped since are pruned. Servers added at runtime
    # (e.g. by the Codex app) were never recorded, so they are left alone.
    managed_path = config_path.with_name(".hm-managed-mcp-servers.json")
    previously_managed = set(json.loads(managed_path.read_text())) if managed_path.exists() else set()
    declared = static.get("mcp_servers", {})
    servers = merged.get("mcp_servers", {})
    for name in previously_managed - declared.keys():
        servers.pop(name, None)
    servers.update(declared)
    if servers:
        merged["mcp_servers"] = servers
    else:
        merged.pop("mcp_servers", None)

    config_path.write_text(tomli_w.dumps(merged))
    managed_path.write_text(json.dumps(sorted(declared)))
    PY
  '';
in {
  options.programs.codex = {
    syncDaemon = lib.mkEnableOption ''
      synchronizing the Codex background server with the installed CLI during
      activation. A version change can interrupt active or queued chats
    '';

    pets = mkOption {
      type = types.attrsOf petType;
      default = {};
      description = ''
        Custom terminal pets installed under {file}`CODEX_HOME/pets`.
        Select one with {command}`/pets` or declare
        {option}`programs.codex.settings.tui.pet = "custom:<name>"`.
        V2 sheets retain their original source and are adapted to the CLI's
        nine-row layout at build time.
      '';
    };

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
    assertions =
      lib.mapAttrsToList (name: _: {
        assertion = builtins.match "[A-Za-z0-9][A-Za-z0-9_-]*" name != null && name != "disabled";
        message = "Codex pet names must use letters, digits, underscores or hyphens, and cannot be 'disabled'.";
      })
      cfg.pets;

    home.file = lib.mkMerge [
      (lib.mapAttrs' (name: pet:
        lib.nameValuePair "${configDir}/pets/${name}" {
          source = mkPet name pet;
        })
      cfg.pets)
      ## Gate the whole entry, not just `.enable`: a key with only `.enable`
      ## set creates a source-less home.file when upstream writes no config
      ## (e.g. the module imported standalone with no settings).
      (lib.mkIf (cfg.mutableUserSettings && isTomlConfig && mergedSettings != {}) {
        "${configDir}/${configFileName}".enable = lib.mkForce false;
      })
    ];

    home.activation = {
      codexSettingsActivation =
        lib.mkIf (cfg.mutableUserSettings && isTomlConfig && mergedSettings != {})
        (lib.hm.dag.entryAfter ["linkGeneration"] mutableConfigMerger);

      codexDaemon = lib.mkIf (cfg.syncDaemon && cfg.package != null) (lib.hm.dag.entryAfter ["linkGeneration" "codexSettingsActivation"] ''
        if [[ ! -v DRY_RUN ]]; then
          (
            export CODEX_HOME=${lib.escapeShellArg (builtins.dirOf configPath)}
            codex_bin=${lib.escapeShellArg (lib.getExe' cfg.package "codex")}
            # A probe that is not a single JSON object must not fail activation.
            # Codex returns nonzero for a valid notRunning report, and a broken
            # or chatty probe can emit nothing, a warning, or extra JSON.
            status_code=0
            daemon_status=$("$codex_bin" app-server daemon version 2>/dev/null) || status_code=$?
            if ! ${pkgs.jq}/bin/jq -e 'type == "object"' <<< "$daemon_status" >/dev/null 2>&1; then
              echo "codex daemon sync: skipping, daemon version did not return JSON (status $status_code)" >&2
              exit 0
            fi
            if [[ "$status_code" != 0 ]] && ! ${pkgs.jq}/bin/jq -e '.status == "notRunning"' <<< "$daemon_status" >/dev/null; then
              echo "codex daemon sync: skipping, daemon version exited $status_code" >&2
              exit 0
            fi
            # Leave stopped daemons stopped, including on first activation.
            update_needed=$(${pkgs.jq}/bin/jq -r '
              .cliVersion as $version
              | .status == "running" and .managedCodexVersion != null
                and (.managedCodexVersion != $version
                  or (.appServerVersion != null and .appServerVersion != $version))
            ' <<< "$daemon_status")
            if [[ "$update_needed" == true ]]; then
              run "$codex_bin" app-server daemon update --from-cli --yes
            fi
          )
        fi
      '');
    };

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

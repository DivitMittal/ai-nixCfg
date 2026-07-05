{
  config,
  lib,
  pkgs,
  talon-nix,
  talon-community,
  ...
}: let
  inherit (lib) mkEnableOption mkIf mkOption types;

  cfg = config.programs.talon;
  system = pkgs.stdenv.hostPlatform.system;
  talonNixPackage =
    if pkgs.stdenv.isLinux
    then talon-nix.packages.${system}.default or null
    else null;
  package =
    if cfg.package != null
    then cfg.package
    else talonNixPackage;

  formatListValue = value:
    if lib.isBool value
    then lib.boolToString value
    else toString value;

  formatList = entries:
    lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: "${name}: ${formatListValue value}") entries) + "\n";

  fileHasText = file: file.text != null;
  fileHasSource = file: file.source != null;
  fileConfig = file:
    if fileHasSource file
    then {inherit (file) source;}
    else {inherit (file) text;};

  talonFileType = types.submodule ({name, ...}: {
    options = {
      text = mkOption {
        type = types.nullOr types.lines;
        default = null;
        description = "Inline contents for the Talon user file.";
      };

      source = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Source file or directory to link into Talon's user directory.";
      };

      target = mkOption {
        type = types.str;
        default = name;
        description = "Path relative to Talon's user directory.";
      };
    };
  });
in {
  options.programs.talon = {
    enable = mkEnableOption "Talon Voice";

    package = mkOption {
      type = types.nullOr types.package;
      default = null;
      description = "Talon package to install. Defaults to talon-nix when available for the current system.";
    };

    userDir = mkOption {
      type = types.str;
      default = ".talon/user";
      description = "Home-relative Talon user directory.";
    };

    enableTalonCommunity = mkOption {
      type = types.bool;
      default = true;
      description = "Install talon-community into the Talon user directory.";
    };

    files = mkOption {
      type = types.attrsOf talonFileType;
      default = {};
      description = "Talon DSL, Python, list, or support files to write into the Talon user directory.";
      example = lib.literalExpression ''
        {
          "custom/hello.talon".text = "os: mac\n-\nhello world: insert(\"hello from nix\")\n";
          "custom/actions.py".source = ./talon/actions.py;
        }
      '';
    };

    lists = mkOption {
      type = types.attrsOf (types.attrsOf types.anything);
      default = {};
      description = "Talon .talon-list files generated from name/value entries, keyed by target path relative to the Talon user directory.";
      example = lib.literalExpression ''
        {
          "custom/vocabulary.talon-list" = {
            repo = "repository";
          };
        }
      '';
    };

    settings = mkOption {
      type = types.attrsOf types.anything;
      default = {};
      description = "Deprecated alias for entries written to settings.talon-list. Prefer programs.talon.lists.";
    };
  };

  config = mkIf cfg.enable (lib.mkMerge [
    {
      assertions =
        lib.mapAttrsToList (name: file: {
          assertion = (fileHasText file) != (fileHasSource file);
          message = "programs.talon.files.${name} must set exactly one of text or source.";
        })
        cfg.files
        ++ [
          {
            assertion = cfg.settings == {} || !(builtins.hasAttr "settings.talon-list" cfg.lists);
            message = "programs.talon.settings and programs.talon.lists.\"settings.talon-list\" cannot both be set.";
          }
        ];

      warnings =
        lib.optional (pkgs.stdenv.isLinux && package == null) ''
          programs.talon is enabled, but talon-nix does not provide a Talon package for ${system}. Only Talon user files will be managed unless programs.talon.package is set.
        ''
        ++ lib.optional (pkgs.stdenv.isLinux && package != null) ''
          programs.talon installs the user package and files only. Talon on Linux may also need system-level udev integration; enable the upstream talon-nix NixOS module in the host configuration when needed.
        '';
    }

    (mkIf (package != null) {
      home.packages = [package];
    })

    (mkIf cfg.enableTalonCommunity {
      home.file."${cfg.userDir}/community".source = talon-community;
    })

    {
      home.file =
        lib.mapAttrs' (_: file:
          lib.nameValuePair "${cfg.userDir}/${file.target}" (fileConfig file))
        cfg.files
        // lib.mapAttrs' (name: entries:
          lib.nameValuePair "${cfg.userDir}/${name}" {text = formatList entries;})
        cfg.lists;
    }

    (mkIf (cfg.settings != {}) {
      home.file."${cfg.userDir}/settings.talon-list".text = formatList cfg.settings;
    })
  ]);
}

# Home Manager Module Patterns

## Module Structure
```nix
{ config, lib, pkgs, ... }:
let
  cfg = config.programs.myProgram;
in {
  options.programs.myProgram = {
    enable = lib.mkEnableOption "myProgram";
    package = lib.mkPackageOption pkgs "myProgram" {};
    settings = lib.mkOption {
      type = lib.types.attrsOf lib.types.anything;
      default = {};
      description = "Configuration options";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
    xdg.configFile."myProgram/config.json".source =
      pkgs.formats.json {}.generate "config.json" cfg.settings;
  };
}
```

## Common Patterns
- Use `xdg.configFile` for dotfiles
- Use `home.file` for non-XDG locations
- Use `pkgs.formats.*` for config generation
- Prefer `lib.mkPackageOption` over manual package options
- Use `lib.mkMerge` for conditional config sections

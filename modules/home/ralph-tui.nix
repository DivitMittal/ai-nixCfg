{
  config,
  lib,
  pkgs,
  customLib,
  ...
}: let
  cfg = config.programs.ralph-tui;

  # Themes bundled inside ralph-tui's dist (assets/themes/*.json).
  # Source: subsy/ralph-tui -> src/tui/theme.ts, BUNDLED_THEMES.
  bundledThemes = ["bright" "catppuccin" "dracula" "high-contrast" "solarized-light"];

  # Unwrapped `pnpm dlx` shim. Owned here so the themed wrapper below is the
  # single installed `ralph-tui` command.
  ralph-tui-bin = customLib.mkPnpmDlxBin pkgs "ralph-tui" "ralph-tui";

  # `--theme` value: a bundled name or a custom JSON path. `null` means no flag
  # is passed, falling back to ralph-tui's built-in Tokyo Night palette.
  themeArg =
    if cfg.themeFile != null
    then toString cfg.themeFile
    else if cfg.theme == "default"
    then null
    else cfg.theme;

  # Appends `--theme <arg>` unless the caller already passed one (allowing a
  # per-invocation override). ralph-tui reads the subcommand from argv[1], so the
  # flag must come AFTER the user's args; it also ignores `--theme` on non-TUI
  # subcommands (config/doctor/setup/...), which makes a global append safe.
  ralph-tui =
    if themeArg == null
    then ralph-tui-bin
    else
      pkgs.writeShellScriptBin "ralph-tui" ''
        for a in "$@"; do
          [ "$a" = "--theme" ] && exec ${ralph-tui-bin}/bin/ralph-tui "$@"
        done
        exec ${ralph-tui-bin}/bin/ralph-tui "$@" --theme ${lib.escapeShellArg themeArg}
      '';
in {
  options.programs.ralph-tui = {
    enable = lib.mkEnableOption "ralph-tui";

    theme = lib.mkOption {
      type = lib.types.enum (["default"] ++ bundledThemes);
      default = "default";
      example = "catppuccin";
      description = ''
        Bundled ralph-tui theme, applied through the `--theme` flag.
        `default` keeps ralph-tui's built-in Tokyo Night palette (no flag).

        ralph-tui's theme loader only accepts opaque `#RRGGBB` colors, so a
        transparent background (e.g. opencode's `background: "none"`) is not
        possible here — use `themeFile` for a custom opaque palette.
      '';
    };

    themeFile = lib.mkOption {
      type = lib.types.nullOr (lib.types.either lib.types.path lib.types.str);
      default = null;
      example = lib.literalExpression "./my-theme.json";
      description = ''
        Path to a custom theme JSON file. Takes precedence over `theme`.
        Every color must be a 6-digit hex code (`#RRGGBB`); `none` and 8-digit
        alpha hex are rejected by ralph-tui at load time.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ralph-tui];
  };
}

{
  config,
  lib,
  pkgs,
  customLib,
  ...
}: let
  cfg = config.programs.gnhf;
  fmt = pkgs.formats.yaml {};
  # gnhf is darwin-broken upstream (fetchPnpmDeps OOMs on macOS — see the
  # `darwinBroken` list in pkgs/default.nix), so install it ephemerally via
  # `pnpm dlx`, the same approach config/home/orchestration/ralph.nix used.
  gnhf-bin = customLib.mkPnpmDlxBin pkgs "gnhf" "gnhf";
in {
  options.programs.gnhf = {
    enable = lib.mkEnableOption "gnhf — “good night, have fun” agent orchestrator";

    settings = lib.mkOption {
      inherit (fmt) type;
      default = {
        agent = "claude";
        maxConsecutiveFailures = 3;
        preventSleep = true;
      };
      description = ''
        gnhf config written to {file}`~/.gnhf/config.yml`.

        gnhf hardcodes its config directory to `~/.gnhf/` (via `os.homedir()`)
        and does **not** honor {env}`XDG_CONFIG_HOME`, so the file is placed
        there — not under {file}`~/.config/` — to keep gnhf functional.
        Schema reference: https://github.com/kunchenguid/gnhf#configuration
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [gnhf-bin];
    home.file.".gnhf/config.yml".source = fmt.generate "gnhf-config.yml" cfg.settings;
  };
}

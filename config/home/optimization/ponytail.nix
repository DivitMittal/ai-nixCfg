{pkgs, ...}: let
  jsonFormat = pkgs.formats.json {};
in {
  # Ponytail: "lazy senior dev" Claude Code plugin that enforces a decision
  # ladder (native APIs → stdlib → existing deps → one-liners) before writing
  # new code. Install once per project: /plugin marketplace add DietrichGebert/ponytail
  xdg.configFile."ponytail/config.json".source = jsonFormat.generate "ponytail-config" {
    defaultMode = "full";
  };
}

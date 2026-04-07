{lib, ...}: let
  common = import ../common {inherit lib;};
  inherit (common.lib) mkYamlFrontmatter;
  inherit (common.commands) commandMeta commandNames readCommand;

  mkCommand = name: let
    meta = commandMeta.${name};
    body = readCommand name;
    frontmatter =
      {inherit (meta) description;}
      // lib.optionalAttrs (meta ? argument-hint) {inherit (meta) argument-hint;}
      // lib.optionalAttrs (meta ? tools) {inherit (meta) tools;};
  in
    mkYamlFrontmatter frontmatter + body;
in {
  programs.github-copilot = {
    commands = lib.genAttrs commandNames mkCommand;
  };
}

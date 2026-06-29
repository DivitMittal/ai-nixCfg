{inputs, ...}: {
  imports = [inputs.sandnix.flakeModule];

  perSystem = {pkgs, ...}: {
    sandnixApps.claude-sandboxed = {
      program = "${pkgs.claude-code}/bin/claude";
      features = {
        tty = true;
        nix = true;
        network = true;
      };
      cli = {
        rw = [
          "$HOME/.claude"
          "$HOME/.claude.json"
        ];
        rwx = ["."];
        env = [
          "HOME"
          "ANTHROPIC_API_KEY"
          "ANTHROPIC_BASE_URL"
          "ANTHROPIC_MODEL"
          "CLAUDE_CODE_USE_VERTEX"
          "CLAUDE_CODE_DISABLE_EXPERIMENTAL_BETAS"
        ];
      };
    };
  };
}

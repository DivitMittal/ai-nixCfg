{
  common-on,
  common-permissions,
  common-actions,
  ...
}: {
  flake.actions-nix.workflows.".github/workflows/flake-check.yml" = {
    on = common-on;
    jobs.checking-flake = {
      permissions = common-permissions;
      # Native runners can realise platform-specific import-from-derivation
      # sources; evaluating every system on Linux cannot.
      runs-on = "\${{ matrix.runner }}";
      strategy = {
        fail-fast = false;
        matrix.runner = ["ubuntu-latest" "ubuntu-24.04-arm" "macos-latest" "macos-15-intel"];
      };
      steps =
        common-actions
        ++ [
          {
            # Flake check's read-only evaluation cannot realise source imports.
            name = "Evaluate the native app and realise its source imports";
            run = ''
              system=$(nix eval --impure --raw --expr builtins.currentSystem)
              nix eval --impure --show-trace --raw ".#apps.$system.ai.program"
            '';
          }
          {
            name = "Run nix flake check";
            run = "nix -vL flake check --impure --no-build --show-trace";
          }
          {
            # --no-build only evaluates; this runs module-tests, crush-config
            # and the pre-commit hooks natively on each platform.
            name = "Build checks";
            run = "nix -L flake check --impure --show-trace";
          }
        ];
    };
  };
}

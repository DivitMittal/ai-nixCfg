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
            name = "Run nix flake check";
            run = "nix -vL flake check --impure --no-build";
          }
        ];
    };
  };
}

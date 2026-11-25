_: {
  perSystem = {
    pkgs,
    lib,
    system,
    ...
  }: let
    configBundle = import ../cloud/config.nix {inherit lib pkgs;};
    core = {
      inherit (pkgs) git gh jq fd nix alejandra;
      rg = pkgs.ripgrep;
      yq = pkgs.yq-go;
    };
    infra =
      core
      // {
        inherit (pkgs) nil nixd kubectl rtk;
        helm = pkgs.kubernetes-helm;
        tofu = pkgs.opentofu;
      };
    mkTools = profile: tools: let
      commands = builtins.attrNames tools;
      env = pkgs.buildEnv {
        name = "cloud-agent-${profile}-bin";
        paths = builtins.attrValues tools;
        pathsToLink = ["/bin" "/share/man"];
      };
    in
      pkgs.runCommand "cloud-agent-${profile}" {} ''
        mkdir -p "$out"
        ln -s ${env}/bin "$out/bin"
        ln -s ${configBundle} "$out/config"
        cp ${../cloud/smoke.sh} "$out/smoke.sh"
        printf '%s\n' ${lib.escapeShellArgs commands} > "$out/tools"
        printf '%s\n' ${system} ${profile} > "$out/profile"
      '';
  in {
    packages =
      {cloud-agent-config = configBundle;}
      // lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
        cloud-agent-tools = mkTools "core" core;
        cloud-agent-tools-infra = mkTools "infra" infra;
      };

    checks.cloud-agents =
      pkgs.runCommand "cloud-agent-check" {
        nativeBuildInputs =
          [
            (pkgs.python3.withPackages (ps: [ps.pyyaml]))
            pkgs.bash
            pkgs.coreutils
            pkgs.gzip
            pkgs.shellcheck
          ]
          ++ lib.optional pkgs.stdenv.hostPlatform.isLinux pkgs.util-linux;
      } ''
        shellcheck ${../cloud}/*.sh
        python ${../cloud}/test.py ${configBundle}
        touch "$out"
      '';

    devShells = lib.optionalAttrs pkgs.stdenv.hostPlatform.isLinux {
      agent-cloud = pkgs.mkShell {packages = builtins.attrValues core;};
    };
  };
}

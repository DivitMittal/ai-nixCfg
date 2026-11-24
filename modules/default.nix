{inputs, ...}: {
  flake.homeManagerModules = {
    ## Default Import for all modules
    default = {
      lib,
      pkgs,
      ...
    }: {
      _module.args.llm-agents = inputs.llm-agents;
      _module.args.talon-nix = inputs.talon-nix;
      _module.args.talon-community = inputs.talon-community;
      imports = [(inputs.import-tree ./home)];
      # Nixpkgs has no jcode. The selective module sets this too; the default
      # import must, or programs.jcode.enable fails to find a package.
      programs.jcode.package = lib.mkDefault inputs.self.packages.${pkgs.stdenvNoCC.hostPlatform.system}.jcode;
    };

    ## Individual imports (for selective usage)
    codex = import ./home/codex.nix;
    crush = import ./home/crush.nix;
    jcode = {
      lib,
      pkgs,
      ...
    }: {
      imports = [./home/jcode.nix];
      programs.jcode.package = lib.mkDefault inputs.self.packages.${pkgs.stdenvNoCC.hostPlatform.system}.jcode;
    };
    n8n = import ./home/n8n.nix;
    talon = {
      _module.args.talon-nix = inputs.talon-nix;
      _module.args.talon-community = inputs.talon-community;
      imports = [./home/talon.nix];
    };
  };
}

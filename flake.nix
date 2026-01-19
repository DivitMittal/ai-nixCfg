{
  description = "ai-nixCfg's flake";

  outputs = inputs: let
    inherit (inputs.flake-parts.lib) mkFlake;
    specialArgs.customLib = import (inputs.OS-nixCfg + "/lib/custom.nix") {inherit (inputs.nixpkgs) lib;};
  in
    mkFlake {inherit inputs specialArgs;} ({inputs, ...}: {
      systems = import inputs.systems;
      imports = [
        ./flake
        ./modules
        ./pkgs
        ./config
      ];
    });

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";
    devshell = {
      url = "github:numtide/devshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    actions-nix = {
      url = "github:nialov/actions.nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        git-hooks.follows = "git-hooks";
      };
    };
    OS-nixCfg = {
      url = "github:DivitMittal/OS-nixCfg";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ## AI packages
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # aicommit2 = {
    #   #url = "github:DivitMittal/aicommit2";
    #   url = "github:tak-bro/aicommit2";
    #   inputs = {
    #     nixpkgs.follows = "nixpkgs";
    #     flake-parts.follows = "flake-parts";
    #   };
    # };
    lumen = {
      url = "github:jnsahaj/lumen";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
  };

  nixConfig = {
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
  };
}

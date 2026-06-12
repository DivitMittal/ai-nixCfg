{
  description = "ai-nixCfg's flake";

  outputs = inputs: let
    inherit (inputs.flake-parts.lib) mkFlake;
  in
    mkFlake {inherit inputs;} ({inputs, ...}: {
      systems = import inputs.systems;
      imports = [
        (inputs.import-tree ./flake)
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
    import-tree.url = "github:vic/import-tree";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    OS-nixCfg = {
      url = "github:DivitMittal/OS-nixCfg";
      flake = false;
    };

    ### AI packages
    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      # Don't follow our nixpkgs: nixos-25.11 lacks buildPythonApplication finalAttrs
      # support required by some llm-agents packages (e.g. apm).
    };
    aicommit2 = {
      #url = "github:DivitMittal/aicommit2";
      url = "github:tak-bro/aicommit2";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
    lumen = {
      url = "github:jnsahaj/lumen";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };
    ## Hermes Agent (home-manager module from upstream PR #9087)
    hermes-agent-hm = {
      url = "github:yzx9/hermes-agent/feat/home-manager";
      # Don't follow nixpkgs — mirrors the llm-agents pattern; avoids
      # Python finalAttrs compat issues with our pinned nixpkgs.
    };
    ## Openclaw
    nix-steipete-tools = {
      url = "github:openclaw/nix-steipete-tools";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-openclaw = {
      url = "github:openclaw/nix-openclaw";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
    ## Kolu (terminal multiplexer for coding agents)
    kolu.url = "github:juspay/kolu";
    ## Pi (coding-agents)
    coding-agents = {
      url = "github:kissgyorgy/coding-agents";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = ["https://cache.numtide.com"];
    extra-trusted-public-keys = ["niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="];
  };
}

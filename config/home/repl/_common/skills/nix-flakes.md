# Nix Flakes Expertise

## Flake Structure
```nix
{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.hostname = nixpkgs.lib.nixosSystem { ... };
    darwinConfigurations.hostname = darwin.lib.darwinSystem { ... };
    homeConfigurations.user = home-manager.lib.homeManagerConfiguration { ... };
    packages.x86_64-linux.default = ...;
    devShells.x86_64-linux.default = ...;
  };
}
```

## Common Commands
- `nix flake check` - Validate flake
- `nix flake update` - Update all inputs
- `nix flake lock --update-input nixpkgs` - Update single input
- `nix build .#package` - Build specific output
- `nix develop` - Enter dev shell

## Best Practices
- Use `follows` to deduplicate nixpkgs instances
- Pin inputs with `flake.lock`
- Use `flake-parts` for large flakes
- Keep outputs organized with let bindings

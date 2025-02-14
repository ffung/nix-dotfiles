{
  description = "Configuration of Fai Fung";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, darwin, nixpkgs, home-manager, ... }@inputs:
    let
      system = "aarch64-darwin";
      pkgs = nixpkgs.legacyPackages.${system};

      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs.lib) attrValues makeOverridable optionalAttrs singleton;

      nixpkgsConfig = {
        config = {
          allowUnfree = true;
          allowBroken = true;
        };
        overlays = attrValues self.overlays ++ singleton (
          # Substitute in x86 version of packages that don't build on Apple Silicon
          final: prev: (optionalAttrs (prev.stdenv.system == "aarch64-darwin") {
          inherit (final.pkgs-x86)
          ;
          })
        );
      };
    in {
      overlays = {};
      darwinConfigurations = rec {
        "MacBook-of-Fai-Fung" = darwinSystem {
          system = system;
          modules = [
            ./hosts/MacBook-of-Fai-Fung/default.nix
            home-manager.darwinModules.home-manager {
              nixpkgs = nixpkgsConfig;
              # `home-manager` config
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.fai = import ./modules/home.nix;
            }
          ];
        };
      };
    };
}

{
  description = "Configuration of Fai Fung";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # my-nvim.url = "git+file:../my-nvim";
    my-nvim.url = "github:ffung/my-nvim";
    claude-code.url = "github:sadjow/claude-code-nix";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, darwin, my-nvim, claude-code, home-manager, ... }@inputs:
    let
      system = "aarch64-darwin";

      inherit (darwin.lib) darwinSystem;
      inherit (inputs.nixpkgs.lib) attrValues;

      nixpkgsConfig = {
        config = {
          allowUnfree = true;
          allowBroken = true;
        };
        overlays = attrValues self.overlays;
      };
    in {
      overlays = {};
      darwinConfigurations = {
        "MacBook-of-Fai-Fung" = darwinSystem {
          system = system;

          modules = [
            ./hosts/MacBook-of-Fai-Fung/default.nix
            home-manager.darwinModules.home-manager {
              nixpkgs = nixpkgsConfig;
              # `home-manager` config
              home-manager.backupFileExtension = "bak";
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.fai = import ./modules/home.nix;
              home-manager.extraSpecialArgs = {
                inherit my-nvim;
                inherit claude-code;
              };
            }
          ];
        };
      };
    };
}

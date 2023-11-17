{
  description = "Nix for macOS configuration";
  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
  };
  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-23.05-darwin";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.05";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs-darwin";
    };
    systems.url = "github:nix-systems/default";
  };
  outputs = inputs @ {
    self,
    nixpkgs,
    darwin,
    systems,
    home-manager,
    ...
  }: let
    eachSystem = nixpkgs.lib.genAttrs (import systems);
    system = "aarch64-darwin";
  in {
    darwinConfigurations.UNiCORN = darwin.lib.darwinSystem {
      inherit system;
      modules = [
        ./modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps.nix
        ./modules/host-users.nix
        home-manager.darwinModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = inputs;
          home-manager.users.amin = import ./home;
        }
      ];
    };
    formatter = eachSystem (system: nixpkgs.legacyPackages.${system}.alejandra);
  };
}

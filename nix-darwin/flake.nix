{
  nixConfig.experimental-features = ["nix-command" "flakes"];
  inputs = {
    nixpkgs-darwin.url = "github:nixos/nixpkgs/nixpkgs-24.05-darwin";
    nixpkgs.follows = "nixpkgs-darwin";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
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
    home-manager,
    darwin,
    ...
  }: {
    darwinConfigurations.UNiCORN = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
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
    formatter = nixpkgs.legacyPackages.aarch64-darwin.alejandra;
  };
}

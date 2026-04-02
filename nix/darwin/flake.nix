{
  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:lnl7/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    flox.url = "github:flox/flox/latest";
  };

  outputs =
    {
      flox,
      home-manager,
      nix-darwin,
      nixpkgs,
      ...
    }@inputs:
    let
      floxConfig =
        { pkgs, ... }:
        {
          environment.systemPackages = [ flox.packages.${pkgs.system}.default ];
          nix.settings = {
            substituters = [ "https://cache.flox.dev" ];
            trusted-public-keys = [ "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" ];
          };
        };
      homeManagerConfig = {
        home-manager.backupFileExtension = "bak";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.amin = {
          imports = [
            ../common/home/configs.nix
            ../common/home/packages.nix
          ];
        };
      };
      commonModules = [
        floxConfig
        ../common/modules/nix-core.nix
        ./modules/system.nix
        ./modules/apps-common.nix
        home-manager.darwinModules.home-manager
        homeManagerConfig
      ];
      mkHost =
        {
          hostname,
          extraModules ? [ ],
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          system = "aarch64-darwin";
          modules =
            commonModules
            ++ [
              {
                networking = {
                  computerName = hostname;
                  hostName = hostname;
                  localHostName = hostname;
                };
                system.defaults.smb.NetBIOSName = hostname;
                system.primaryUser = "amin";
                users.users.amin = {
                  home = "/Users/amin";
                  description = "amin";
                };
              }
            ]
            ++ extraModules;
        };
    in
    {
      darwinConfigurations.UNiCORN = mkHost {
        hostname = "UNiCORN";
        extraModules = [ ./modules/apps-unicorn.nix ];
      };
      darwinConfigurations.UNiCHARM = mkHost {
        hostname = "UNiCHARM";
        extraModules = [ ./modules/apps-unicharm.nix ];
      };
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;
    };
}

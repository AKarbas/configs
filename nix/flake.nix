{
  inputs = {
    # Single nixpkgs for every output. The -darwin branch is release-26.05
    # plus darwin-only fixes; its linux package set is release-26.05's.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-26.05-darwin";
    nix-darwin.url = "github:lnl7/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    flox.url = "github:flox/flox/latest";
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
  };

  outputs =
    {
      determinate,
      flox,
      home-manager,
      nix-darwin,
      nixpkgs,
      ...
    }@inputs:
    let
      homeModules = [
        ./common/home/configs.nix
        ./common/home/packages.nix
      ];
      homeSpecialArgs = system: {
        pkgs-unstable = import inputs.nixpkgs-unstable {
          inherit system;
          config.allowUnfree = true;
        };
        flox = flox.packages.${system}.default;
      };

      # home-manager-as-module config, shared by darwin and NixOS hosts.
      mkHomeManagerConfig = system: {
        home-manager.backupFileExtension = "bak";
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.extraSpecialArgs = homeSpecialArgs system;
        home-manager.users.amin.imports = homeModules;
      };

      floxCache = {
        extra-substituters = [ "https://cache.flox.dev" ];
        extra-trusted-public-keys = [ "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs=" ];
      };

      darwinModules = [
        determinate.darwinModules.default
        { determinateNix.customSettings = floxCache; }
        ./darwin/modules/use-case-hack.nix
        ./common/modules/nix-core.nix
        ./darwin/modules/system.nix
        ./darwin/modules/apps-common.nix
        home-manager.darwinModules.home-manager
        (mkHomeManagerConfig "aarch64-darwin")
      ];
      mkDarwinHost =
        {
          hostname,
          computerName ? hostname,
          netbiosName ? hostname,
          extraModules ? [ ],
        }:
        nix-darwin.lib.darwinSystem {
          specialArgs = { inherit inputs; };
          system = "aarch64-darwin";
          modules =
            darwinModules
            ++ [
              {
                networking = {
                  inherit computerName;
                  hostName = hostname;
                  localHostName = hostname;
                };
                system.defaults.smb.NetBIOSName = netbiosName;
                system.primaryUser = "amin";
                users.users.amin = {
                  home = "/Users/amin";
                  description = "amin";
                };
              }
            ]
            ++ extraModules;
        };

      nixosModules = [
        determinate.nixosModules.default
        { nix.settings = floxCache; }
        ./nixos/modules/system.nix
        ./nixos/modules/host-users.nix
        ./common/modules/nix-core.nix
        home-manager.nixosModules.home-manager
        (mkHomeManagerConfig "x86_64-linux")
      ];

      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      allSystems = linuxSystems ++ [ "aarch64-darwin" ];
    in
    {
      darwinConfigurations.Amin-Karbas-MacBook-Pro = mkDarwinHost {
        hostname = "Amin-Karbas-MacBook-Pro";
        computerName = "Amin Karbas - MacBook Pro";
        netbiosName = null;
        extraModules = [ ./darwin/modules/apps-amin-karbas-macbook-pro.nix ];
      };
      darwinConfigurations.UNiCHARM = mkDarwinHost {
        hostname = "UNiCHARM";
        extraModules = [ ./darwin/modules/apps-unicharm.nix ];
      };

      # Standalone home-manager for foreign-distro (non-NixOS) Linux hosts.
      homeConfigurations.amin-linux = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        extraSpecialArgs = homeSpecialArgs "x86_64-linux";
        modules = homeModules ++ [ ./common/home/linux-foreign.nix ];
      };

      nixosConfigurations.UNiXOS = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = nixosModules ++ [ ./nixos/modules/hardware-configuration.nix ];
      };

      # Installer ISOs (native builds only; needs a builder for the target
      # system).
      packages = nixpkgs.lib.genAttrs linuxSystems (system: {
        iso =
          (nixpkgs.lib.nixosSystem {
            inherit system;
            modules = nixosModules ++ [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
              # The installer pulls in zfs; 26.11's default, silences the warning.
              { boot.zfs.forceImportRoot = false; }
            ];
          }).config.system.build.isoImage;
      });

      formatter = nixpkgs.lib.genAttrs allSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-tree);
    };
}

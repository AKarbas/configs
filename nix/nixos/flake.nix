{
  nixConfig = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flox = {
      url = "github:flox/flox";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      flox,
      nixos-generators,
      ...
    }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      supportedHostSystems = supportedSystems ++ [
        "aarch64-darwin"
        "x86_64-darwin"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      # Create a nixpkgs instance for each supported host system
      nixpkgsFor = nixpkgs.lib.genAttrs supportedHostSystems (system: import nixpkgs { inherit system; });

      # Helper function to determine if cross-compilation is needed
      pkgsForSystem =
        targetSystem: hostSystem:
        if (builtins.elem hostSystem supportedSystems) then
          nixpkgsFor.${targetSystem}
        else
          import nixpkgs {
            system = hostSystem;
            crossSystem = targetSystem;
          };

      commonModules = [
        ./modules/system.nix
        ./modules/host-users.nix
        ../common/modules/nix-core.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit flox; };
          home-manager.users.amin =
            { ... }:
            {
              imports = [
                ../common/home/configs.nix
                ../common/home/packages.nix
              ];
            };
        }
      ];
      mkNixosSystem =
        system:
        {
          extraModules ? [ ],
          ...
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs.flox = flox;
          modules = commonModules ++ extraModules;
        };
      mkIsoPackages =
        hostSystem:
        forAllSystems (targetSystem: {
          iso = nixos-generators.nixosGenerate {
            pkgs = pkgsForSystem targetSystem hostSystem;
            modules = commonModules ++ [
              "${nixpkgs}/nixos/modules/installer/cd-dvd/installation-cd-minimal.nix"
            ];
            format = "iso";
          };
        });
    in
    {
      nixosConfigurations = forAllSystems (system: {
        nixos = mkNixosSystem system { extraModules = [ ./modules/hardware-configuration.nix ]; };
      });
      packages = nixpkgs.lib.genAttrs supportedHostSystems mkIsoPackages;
      formatter = nixpkgs.lib.genAttrs supportedHostSystems (
        system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style
      );
    };
}

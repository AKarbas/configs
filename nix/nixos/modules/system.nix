{
  config,
  lib,
  pkgs,
  ...
}:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    # Beats gnome's mkDefault true, loses to the installer ISO profile's true.
    networkmanager.enable = lib.mkOverride 999 false;
    hostName = "UNiXOS";
  };

  # Enable X11 windowing system
  services.xserver.enable = true;
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

  # Enable OpenGL
  hardware.graphics.enable = true;

  # System packages
  environment = {
    systemPackages = with pkgs; [
      curl
      git
      neovim
      tailscale
      wget
      zsh
    ];
    shells = with pkgs; [ zsh ];
  };

  environment.variables.EDITOR = "nvim";

  nix.optimise.automatic = true;

  fonts.packages = with pkgs; [
    material-design-icons
    font-awesome
    nerd-fonts.fira-code
  ];

  programs.zsh.enable = true;

  services.tailscale.enable = true;

  system.stateVersion = "24.11";
}

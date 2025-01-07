{ config, pkgs, ... }:
{
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking = {
    networkmanager.enable = false;
    hostName = "UNiXOS";
  };

  # Enable X11 windowing system
  services.xserver = {
    enable = true;
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

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

  fonts.packages = with pkgs; [
    material-design-icons
    font-awesome
    (nerdfonts.override { fonts = [ "FiraCode" ]; })
  ];

  programs.zsh.enable = true;

  services.tailscale.enable = true;

  system.stateVersion = "24.11";
}

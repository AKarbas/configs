{ config, pkgs, ... }:
{
  users.users.amin = {
    isNormalUser = true;
    home = "/home/amin";
    extraGroups = [
      "wheel"
      "networkmanager"
      "docker"
    ];
    shell = pkgs.zsh;
  };

  # Enable sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;

  # Enable docker
  virtualisation.docker.enable = true;
}

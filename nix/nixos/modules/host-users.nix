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
    linger = true; # see enableLinger in common/home/linux-foreign.nix
  };

  # Enable sudo without password for wheel group
  security.sudo.wheelNeedsPassword = false;

  virtualisation.docker.enable = true;
}

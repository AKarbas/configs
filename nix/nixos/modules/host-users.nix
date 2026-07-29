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

  # Enable docker (25.11's default docker_28 is marked insecure)
  virtualisation.docker = {
    enable = true;
    package = pkgs.docker_29;
  };
}

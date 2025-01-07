# This file will be overwritten by nixos-generate-config
# Do not modify it manually
{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:
{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];
  # Boot and filesystem settings will be added by nixos-generate-config
}

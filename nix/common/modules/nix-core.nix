{
  pkgs,
  lib,
  ...
}:
{
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 1w";
  };
  nix.package = pkgs.nixVersions.latest;
  nix.optimise.automatic = true;
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nixpkgs.config.allowUnfree = true;
  services.nix-daemon.enable = true;
}

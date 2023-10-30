{
  pkgs,
  lib,
  ...
}: {
  nix.gc = {
    automatic = lib.mkDefault true;
    options = lib.mkDefault "--delete-older-than 1w";
  };
  nix.package = pkgs.nix;
  nix.settings.auto-optimise-store = true;
  nix.settings.experimental-features = ["nix-command" "flakes"];
  nixpkgs.config.allowUnfree = true;
  programs.nix-index.enable = true;
  services.nix-daemon.enable = true;
}

{ pkgs, lib, config, ... }:
{
  # The nix.* configs will be unavailable on MacOS (or Linux) if Determinate's
  # nix distribution is used.
  nix = lib.mkIf config.nix.enable {
    gc = {
      automatic = lib.mkDefault true;
      options = lib.mkDefault "--delete-older-than 1w";
    };
    package = pkgs.nixVersions.latest;
    optimise.automatic = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
  nixpkgs.config.allowUnfree = true;
}

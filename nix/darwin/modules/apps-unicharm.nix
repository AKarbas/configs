{ pkgs, ... }:
{
  # UNiCHARM-specific apps. Move items from apps-common.nix here as needed.
  environment.systemPackages = with pkgs; [ tailscale ];
  services.tailscale.enable = true;
  homebrew = {
    brews = [ ];
    casks = [
      "electrum"
      "iina"
      "insta360-studio"
      "steam"
    ];
    masApps = { };
  };
}

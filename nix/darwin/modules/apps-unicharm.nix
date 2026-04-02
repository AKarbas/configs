{ ... }:
{
  # UNiCHARM-specific apps. Move items from apps-common.nix here as needed.
  homebrew = {
    brews = [ ];
    casks = [
      "electrum"
      "iina"
      "steam"
    ];
    masApps = { };
  };
}

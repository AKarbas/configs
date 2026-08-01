{ pkgs, lib, ... }:
{
  # Standalone home-manager on a foreign (non-NixOS) distro.
  # Nix comes from the Determinate installer, which manages the daemon
  # config itself — mirror darwin's `nix.enable = false` (packages.nix then
  # also skips adding a second `nix` to the profile).
  nix.enable = false;

  # Source the nix profile and fix XDG vars in generated shell configs on
  # non-NixOS hosts.
  targets.genericLinux.enable = true;

  home.packages = [ pkgs.nerd-fonts.fira-code ];

  programs.bash = {
    enable = true;
    initExtra = ''
      [ -z "$ZSH_VERSION" ] && [ -z "$_NO_ZSH" ] && [ -x "$HOME/.nix-profile/bin/zsh" ] && exec "$HOME/.nix-profile/bin/zsh" -l
    '';
  };
}

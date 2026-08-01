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

  # chsh cannot set the login shell when the user is not in /etc/passwd.
  # Keep bash as the login shell and hand interactive shells to zsh.
  # Escape hatch: run `_NO_ZSH=1 bash` to stay in bash.
  programs.bash = {
    enable = true;
    initExtra = ''
      [ -z "$ZSH_VERSION" ] && [ -z "$_NO_ZSH" ] && [ -x "$HOME/.nix-profile/bin/zsh" ] && exec "$HOME/.nix-profile/bin/zsh" -l
    '';
  };
}

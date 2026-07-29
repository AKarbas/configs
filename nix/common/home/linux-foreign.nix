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

  # The nix-store zsh is only a valid login shell once it's in /etc/shells
  # (needs root, once). chsh itself can also fail, so never fail the
  # switch — print the manual steps instead.
  home.activation.zshLoginShell = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _zsh="${pkgs.zsh}/bin/zsh"
    if [ "''${SHELL:-}" != "$_zsh" ]; then
      if grep -qF "$_zsh" /etc/shells 2>/dev/null; then
        $DRY_RUN_CMD chsh -s "$_zsh" || true
      else
        echo "To make zsh the login shell:"
        echo "  echo '$_zsh' | sudo tee -a /etc/shells && chsh -s '$_zsh'"
      fi
    fi
  '';
}

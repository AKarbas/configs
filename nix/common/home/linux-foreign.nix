{
  config,
  pkgs,
  lib,
  ...
}:
let
  # `make hm` evaluates with --impure, so the config uses the host's user and
  # home. Pure evaluation cannot read them and keeps the defaults.
  hostUser = builtins.getEnv "USER";
  hostHome = builtins.getEnv "HOME";
in
{
  # Standalone home-manager on a foreign (non-NixOS) distro.
  # Source the nix profile and fix XDG vars in generated shell configs on
  # non-NixOS hosts.
  targets.genericLinux.enable = true;
  targets.genericLinux.gpu.enable = false;

  home.username = lib.mkIf (hostUser != "") hostUser;
  home.homeDirectory = lib.mkIf (hostHome != "") hostHome;
  assertions = [
    {
      assertion = hostUser != "root";
      message = "Do not run `make hm` with sudo. The config reads the user and home from the environment.";
    }
  ];

  home.packages = [ pkgs.nerd-fonts.fira-code ];

  # systemd stops user@<uid>.service after the last logout unless the user
  # lingers, killing anything started under it via systemd-run --user (e.g.
  # agent-deck's tmux servers). Plain tmux sits in the login scope and is
  # unaffected either way. Hosts without systemd have nothing to linger.
  home.activation.enableLinger = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    _loginctl=/usr/bin/loginctl
    if [ -d /run/systemd/system ] \
      && [ "$($_loginctl show-user "$UID" -p Linger --value 2>/dev/null)" != "yes" ]; then
      $DRY_RUN_CMD $_loginctl enable-linger
    fi
  '';

  programs.bash = {
    enable = true;
    # bashrcExtra lands above .bashrc's interactive guard, and sshd-invoked
    # bash sources .bashrc even for non-interactive commands — so this is
    # what puts sessionPath on PATH for plain `ssh <host> <cmd>`. The
    # session-vars script is sentinel-guarded, so login shells re-sourcing
    # it are a no-op.
    bashrcExtra = ''
      . "${config.home.profileDirectory}/etc/profile.d/hm-session-vars.sh"
    '';
    initExtra = ''
      [ -z "$ZSH_VERSION" ] && [ -z "$_NO_ZSH" ] && [ -x "$HOME/.nix-profile/bin/zsh" ] && exec "$HOME/.nix-profile/bin/zsh" -l
    '';
  };
}

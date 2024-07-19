{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    shellAliases = {
      l = "ls -ahl";
    };
    profileExtra = ''
      export PATH=\"$PATH:/opt/homebrew/bin/\"
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "docker"
        "fzf"
        "macos"
        "z"
        "git"
      ];
    };
  };
}

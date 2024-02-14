{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.direnv.enable = true;
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    shellAliases = {
      l = "ls -ahl";
    };
    history.extended = true;
    oh-my-zsh = {
      enable = true;
      plugins = [
        "fzf"
        "macos"
        "z"
        "git"
      ];
    };
  };
}

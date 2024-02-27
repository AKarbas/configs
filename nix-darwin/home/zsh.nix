{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.direnv.enable = true;
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    autocd = true;
    shellAliases = {
      l = "ls -ahl";
    };
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

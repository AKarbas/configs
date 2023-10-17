{ config, lib, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableCompletion = true;
    autocd = true;
    shellAliases = {
      l = "ls -ahl";
    };
    history = {
      extended = true;
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "fzf"
        "osx"
        "z"
        "git"
      ];
    };
  };
}

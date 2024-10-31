{
  config,
  lib,
  pkgs,
  ...
}: {
  home = {
    sessionPath = [
      "/opt/homebrew/bin/"
    ];
    sessionVariables = {
      KUBECONFIG = "${config.home.homeDirectory}/.kube/config";
    };
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.zsh = {
    autocd = true;
    autosuggestion.enable = true;
    enable = true;
    enableCompletion = true;
    historySubstringSearch.enable = true;
    syntaxHighlighting.enable = true;
    shellAliases = {
      l = "ls -ahl";
    };
    initExtra = ''
      ###-begin-gt-completions-###
      _gt_yargs_completions()
      {
        local reply
        local si=$IFS
        IFS=$'
      ' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" gt --get-yargs-completions "$${words[@]}"))
        IFS=$si
        _describe 'values' reply
      }
      command -v compdef >/dev/null || (autoload -Uz compinit && compinit)
      compdef _gt_yargs_completions gt
      ###-end-gt-completions-###
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aws"
        "docker"
        "fzf"
        "kubectl"
        "kubectx"
        "kube-ps1"
        "macos"
        "z"
        "git"
      ];
    };
  };
}

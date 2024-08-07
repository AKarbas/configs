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
      export PATH="$PATH:/opt/homebrew/bin/"
      export KUBECONFIG=~/.kube/config
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

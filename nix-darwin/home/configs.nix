{
  config,
  lib,
  pkgs,
  ...
}:
{
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f ~/.gitconfig
  '';
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      userName = "Amin Karbas";
      userEmail = "6280244+AKarbas@users.noreply.github.com";
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        advice.detachedHead = false;
      };
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        time = {
          disabled = false;
          utc_time_offset = "0";
          time_format = "%T%.3f";
          format = "[$time]($style)";
        };
      };
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      extraConfig = ''
        set number
      '';
    };
    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
    };
  };
  home = {
    username = "amin";
    homeDirectory = "/Users/amin";
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.11";
    sessionPath = [
      "/opt/homebrew/bin/"
      "${config.home.homeDirectory}/go/bin/"
    ];
    sessionVariables = {
      KUBECONFIG = "${config.home.homeDirectory}/.kube/config";
    };
  };
  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    # This does not work if a config for atuin already exists
    # https://github.com/nix-community/home-manager/issues/5734
    settings = {
      enter_accept = false;
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
    syntaxHighlighting.enable = true;
    shellAliases = {
      l = "ls -ahl";
    };
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aws"
        "docker"
        "fzf"
        "git"
        "kube-ps1"
        "kubectl"
        "kubectx"
        "macos"
        "z"
      ];
      extraConfig = ''
        DISABLE_FZF_KEY_BINDINGS="true"
      '';
    };
    plugins = [
      {
        name = "zsh-vi-mode";
        src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
      }
      {
        name = "fzf-tab";
        src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
      }
    ];
  };
}

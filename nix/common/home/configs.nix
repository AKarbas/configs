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
        advice.skippedCherryPicks = false;
      };
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        character = {
          success_symbol = "[➜](bold green) ";
          error_symbol = "[✗](bold red) ";
          d_symbol = "[V](bold green) ";
        };
        cmd_duration = { min_time = 0; show_milliseconds = true; };
        directory = { fish_style_pwd_dir_length = 3; };
        direnv = {
          disabled = false;
          format = "[$symbol($loaded$allowed)](bold white) ";
          allowed_msg = "✔";
          denied_msg = "✗";
          not_allowed_msg = "🔘";
          loaded_msg = "";
        };
        git_commit = { only_detached = false; tag_disabled = false; };
        git_metrics = { disabled = false; };
        kubernetes = { disabled = false; };
        sudo = { disabled = false; };
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
    homeDirectory = if pkgs.stdenv.isLinux then "/home/amin" else "/Users/amin";
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
    enableNushellIntegration = true;
    enableZshIntegration = true;
    # This does not work if a config for atuin already exists
    # https://github.com/nix-community/home-manager/issues/5734
    settings = {
      enter_accept = false;
      search_mode = "fuzzy";
    };
  };
  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
  programs.nushell = {
    enable = true;
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
    initExtra = ''
      function cling() {
        local folders=()
        for arg in "$@"; do
          if [ -d "$arg" ]; then
            folders+=("$arg")
          else [ -f "$arg" ]
            folders+=("$(dirname "$arg")")
          fi
        done
        open -a Cling "''${folders[@]}"
      }
    '';
    oh-my-zsh = {
      enable = true;
      plugins = [
        "aws"
        "docker"
        "git"
        "kubectl"
        "kubectx"
        "macos"
        "z"
      ];
      extraConfig = ''
        DISABLE_FZF_KEY_BINDINGS="true"
        export ZVM_INIT_MODE=sourcing
        bindkey '^r' _atuin_search_widget
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

{pkgs, ...}: {
  home.packages = with pkgs; [
    age
    axel
    awscli2
    bat
    bazel_7
    bazel-buildtools
    btop
    buf-language-server
    clang-tools
    cmake
    colima
    colordiff
    deno
    direnv
    docker-client
    file
    fzf
    gawk
    gh
    gnumake
    gnupg
    gnused
    gnutar
    go
    htop-vim
    hugo
    jdk
    jq
    k6
    k9s
    kns
    krew
    kubectl
    kubectl-explore
    kubernetes-helm
    kubernetes-helmPlugins.helm-diff
    kubie
    mtr
    ninja
    nix
    nix-index
    nodejs
    nodePackages.nodemon
    nodePackages.ts-node
    p7zip
    parallel
    poetry
    postgresql
    python312
    restic
    ripgrep
    rsync
    rustup
    sbt
    skaffold
    spr
    sshuttle
    terraform
    terragrunt
    texlive.combined.scheme-full
    tmux
    tree
    typescript
    unzip
    uutils-coreutils
    watch
    wget
    which
    wireguard-go
    wireguard-tools
    xz
    yamllint
    yq-go
    zip
    zsh
    zsh-autocomplete
    zsh-completions
    zsh-fast-syntax-highlighting
    zsh-fzf-tab
    zsh-z
    zstd
    (pkgs.writeShellScriptBin "git-spr-single" ''
      #!/bin/bash

      set -e -u -o pipefail

      # Ensure command argument is provided
      if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <command: diff | land> [commit]"
        exit 1
      fi

      command=$1

      # Check if the command is valid
      if [[ "$command" != "diff" && "$command" != "land" ]]; then
        echo "Error: Command must be either 'diff' or 'land'."
        exit 1
      fi

      # Determine the commit
      merge_base=$(git merge-base HEAD origin/main)
      if [[ $# -eq 2 ]]; then
        commit_hash=$(git rev-parse "$2")
      else
        commit=$(git log --oneline $merge_base..HEAD | fzf --layout=reverse-list --height 80% --prompt "Select commit:" --preview "git show {1}")
        [[ -n "$commit" ]]
        commit_hash=$(echo $commit | awk '{print $1}')
      fi

      # Choose the correct spr command based on the provided command
      if [[ "$command" = "diff" ]]; then
              spr_command="spr $command --update-message"
      else
              spr_command="spr $command"
      fi

      # Perform interactive rebase with the selected or provided commit
      GIT_SEQUENCE_EDITOR="perl -i -pe 's/^(pick $commit_hash.*)$/\$1\\nexec $spr_command --cherry-pick /'" git rebase -i $merge_base
    '')
  ];

  programs = {
    # modern vim
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
    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}

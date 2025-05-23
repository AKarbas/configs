{ pkgs, ... }:
let
  makeScript = name: script: pkgs.writeShellScriptBin name (builtins.readFile script);

  standardPackages = with pkgs; [
    act
    awscli2
    axel
    bat
    btop
    buf
    clang-tools
    cmake
    colordiff
    direnv
    docker-client
    duckdb
    fd
    file
    fswatch
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
    jq
    k9s
    kns
    krew
    kubectl
    kubectl-explore
    kubernetes-helm
    kubernetes-helmPlugins.helm-diff
    minikube
    mtr
    ninja
    nix
    nix-index
    nixd
    p7zip
    parallel
    poetry
    poetryPlugins.poetry-plugin-up
    postgresql
    procs
    python313
    ripgrep
    rsync
    skaffold
    spr
    terraform
    terragrunt
    tmux
    tree
    unzip
    uutils-coreutils
    watch
    wget
    which
    xz
    yq-go
    zip
    zstd
  ];

  nushellPackages = with pkgs; [
    nushell
    nushellPlugins.formats
    nushellPlugins.gstat
    nushellPlugins.net
    nushellPlugins.units
  ];

  zshPackages = with pkgs; [
    zsh
    zsh-autocomplete
    zsh-completions
    zsh-fast-syntax-highlighting
    zsh-fzf-tab
    zsh-vi-mode
    zsh-z
  ];

  customScripts = [
    (makeScript "git-spr-single" ./scripts/git-spr-single.sh)
    (makeScript "git-vimdiff" ./scripts/git-vimdiff.sh)
  ];
in
{ home.packages = customScripts ++ nushellPackages ++ zshPackages ++ standardPackages; }

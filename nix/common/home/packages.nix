{ pkgs, ... }:
let
  makeScript = name: script: pkgs.writeShellScriptBin name (builtins.readFile script);

  standardPackages = with pkgs; [
    age
    awscli2
    axel
    bat
    bazel-buildtools
    bazel_7
    btop
    buf
    clang-tools
    cmake
    colordiff
    deno
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
    llm
    minikube
    mtr
    ninja
    nix
    nix-index
    nixd
    nodePackages.nodemon
    nodePackages.ts-node
    nodejs
    ollama
    p7zip
    parallel
    poetry
    poetryPlugins.poetry-plugin-up
    postgresql
    procs
    python313
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
    tilt
    tmux
    tree
    typescript
    unzip
    uutils-coreutils
    watch
    watchman
    wget
    which
    wireguard-go
    wireguard-tools
    xz
    yamllint
    yq-go
    zip
    zstd
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

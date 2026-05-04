{
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
let
  makeScript = name: script: pkgs.writeShellScriptBin name (builtins.readFile script);

  standardPackages = with pkgs; [
    act
    ast-grep
    awscli2
    axel
    bat
    btop
    buf
    clang-tools
    cmake
    colordiff
    delta
    diffnav
    direnv
    docker-client
    duckdb
    fd
    file
    fswatch
    gawk
    gh
    gnumake
    gnupg
    gnused
    gnutar
    go
    helm-ls
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
    nil
    ninja
    nix-index
    nixd
    nixfmt-rfc-style
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
    yazi
    yq-go
    zip
    zstd
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

  customScripts = [ (makeScript "git-spr-single" ./scripts/git-spr-single.sh) ];

  customPackages = [
    # jj-spr is not in nixpkgs.
    (builtins.getFlake "github:LucioFranco/jj-spr/f628b200dcd25e01df1d97677305dc828a396b24")
    .packages.${pkgs.stdenv.hostPlatform.system}.default
    # jj-starship is in nixpkgs-unstable but not in 25.11.
    # Drop this (use pkgs.jj-starship) once 25.11 backports it or on the next channel bump.
    pkgs-unstable.jj-starship
  ];

  maybeNix = if config.nix.enable then [ pkgs.nix ] else [ ];
in
{
  home.packages = customScripts ++ zshPackages ++ standardPackages ++ customPackages ++ maybeNix;
}

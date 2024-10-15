{pkgs, ...}: {
  home.packages = with pkgs; [
    age
    axel
    awscli2
    bat
    bazel_7
    bazel-buildtools
    btop
    clang-tools
    cmake
    colima
    colordiff
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

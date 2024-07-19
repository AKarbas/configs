{pkgs, ...}: {
  home.packages = with pkgs; [
    age
    axel
    bat
    bazel_7
    bazel-buildtools
    btop
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
    iterm2
    jdk
    jq
    mtr
    ninja
    nix
    nix-index
    p7zip
    parallel
    restic
    ripgrep
    rsync
    rustup
    sbt
    sshuttle
    texlive.combined.scheme-full
    tmux
    tree
    unzip
    watch
    which
    wireguard-go
    wireguard-tools
    xz
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

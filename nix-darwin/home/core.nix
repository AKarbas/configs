{ pkgs, ... }:

{
  home.packages = with pkgs; [
    age
    axel
    bat
    btop
    cmake
    colordiff
    discord
    file
    fzf
    gawk
    gnupg
    gnused
    gnutar
    go
    htop-vim
    hugo
    iterm2
    jetbrains.clion
    jq
    mtr
    ninja
    nix-index
    p7zip
    parallel
    ripgrep
    rsync
    slack
    sshuttle
    texlive.combined.scheme-full
    tmux
    tree
    unzip
    vscode
    which
    wireguard-go
    wireguard-tools
    xz
    yq-go
    zip
    zoom-us
    zsh
    zsh-autocomplete
    zsh-completions
    zsh-fast-syntax-highlighting
    zsh-fzf-tab
    zsh-you-should-use
    zsh-z
    zstd
  ];

  programs = {
    # modern vim
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
    };

    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    exa = {
      enable = true;
      enableAliases = true;
      git = true;
      icons = true;
    };

    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}

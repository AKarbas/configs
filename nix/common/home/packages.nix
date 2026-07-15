{
  pkgs,
  pkgs-unstable,
  config,
  ...
}:
let
  makeScript = name: script: pkgs.writeShellScriptBin name (builtins.readFile script);

  # Piped diff tools can't see the terminal background and default to dark, so
  # the wrappers below pass --dark/--light from the effective macOS appearance.
  # Only SkyLight (the WindowServer) tracks it: under Auto appearance, the
  # AppleInterfaceStyle plist key (and System Events, which reads it) says
  # "Dark" even during the light phase. Prints nothing off-macOS/over ssh.
  macosTheme = pkgs.writeCBin "macos-theme" ''
    #include <dlfcn.h>
    #include <stdio.h>
    int main(void) {
      void *skylight = dlopen(
        "/System/Library/PrivateFrameworks/SkyLight.framework/SkyLight",
        RTLD_LAZY);
      int (*theme)(void) =
        skylight ? (int (*)(void))dlsym(skylight, "SLSGetAppearanceThemeLegacy") : 0;
      if (!theme) return 1;
      puts(theme() == 1 ? "dark" : "light");
      return 0;
    }
  '';

  themedDelta = pkgs.writeShellScriptBin "delta" ''
    case $(${macosTheme}/bin/macos-theme) in
      dark)  exec ${pkgs.delta}/bin/delta --dark "$@" ;;
      light) exec ${pkgs.delta}/bin/delta --light "$@" ;;
      *)     exec ${pkgs.delta}/bin/delta "$@" ;;
    esac
  '';

  # difftastic: unstable's is much newer than 25.11's.
  themedDifft = pkgs.writeShellScriptBin "difft" ''
    # difft assumes 80 columns when piped.
    if [ -z "$DFT_WIDTH" ] && [ -r /dev/tty ]; then
      cols=$(stty size 2>/dev/null </dev/tty | cut -d' ' -f2)
      [ -n "$cols" ] && export DFT_WIDTH="$cols"
    fi
    case $(${macosTheme}/bin/macos-theme) in
      dark)  exec ${pkgs-unstable.difftastic}/bin/difft --background dark "$@" ;;
      light) exec ${pkgs-unstable.difftastic}/bin/difft --background light "$@" ;;
      *)     exec ${pkgs-unstable.difftastic}/bin/difft "$@" ;;
    esac
  '';

  standardPackages = with pkgs; [
    act
    ast-grep
    awscli2
    axel
    bat
    btop
    buf
    clang-tools
    claude-code
    cmake
    colordiff
    themedDelta
    themedDifft
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
    opentofu
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

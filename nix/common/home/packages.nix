{
  pkgs,
  pkgs-unstable,
  flox,
  ...
}:
let
  makeZshScript =
    name: script:
    pkgs.writeScriptBin name ''
      #!${pkgs.zsh}/bin/zsh
      source ${./scripts}/${script} "$@"
    '';

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

  # difftastic: unstable's is much newer than 26.05's.
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

  # Not in nixpkgs.
  plannotator =
    let
      version = "0.28.22";
      asset =
        {
          x86_64-linux = {
            name = "linux-x64";
            hash = "sha256-JVqPA2TYbYu/AdNskz6TaK1iethJgvxxHiAtN1bT/6w=";
          };
          aarch64-linux = {
            name = "linux-arm64";
            hash = "sha256-1OvlaCA3tdEbM/Zpb967sQq/dH3qRon+bfFREppkIUo=";
          };
          aarch64-darwin = {
            name = "darwin-arm64";
            hash = "sha256-qDoJggD7CzAu7jS3OeahEi2uZedZ33tVGSVcEn4MFKk=";
          };
        }
        .${pkgs.stdenv.hostPlatform.system};
    in
    pkgs.runCommand "plannotator-${version}" { } ''
      install -Dm755 ${
        pkgs.fetchurl {
          url = "https://github.com/backnotprop/plannotator/releases/download/v${version}/plannotator-${asset.name}";
          inherit (asset) hash;
        }
      } $out/bin/plannotator
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
    cmake
    colordiff
    themedDelta
    themedDifft
    direnv
    (docker_29.override { clientOnly = true; })
    duckdb
    dust
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
    jj-starship
    jjui
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
    nixfmt
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
    zellij
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

  customScripts = [
    (makeZshScript "ghs" "gh-stack.zsh")
  ];

  customPackages = [
    flox
    plannotator
    # jj-spr is not in nixpkgs.
    (builtins.getFlake "github:LucioFranco/jj-spr/f628b200dcd25e01df1d97677305dc828a396b24")
    .packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
in
{
  home.packages = customScripts ++ zshPackages ++ standardPackages ++ customPackages;
}

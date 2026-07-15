{ config, lib, pkgs, ... }:
let
  # Homebrew 6.0 refuses to load formulae/casks from non-official taps during
  # `brew bundle` unless the tap is trusted. Derive the trusted taps from the
  # formulae/casks so the trust store can't drift from the Brewfile.
  tapOf =
    fullName:
    let
      parts = lib.splitString "/" fullName;
    in
    lib.optional (builtins.length parts == 3) (lib.concatStringsSep "/" (lib.take 2 parts));
  trustedTaps = lib.unique (
    lib.concatMap (entry: tapOf entry.name) (config.homebrew.brews ++ config.homebrew.casks)
  );
  homebrewTrustStore = (pkgs.formats.json { }).generate "homebrew-trust.json" {
    trustedtaps = trustedTaps;
  };
in
{
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    curl
    git
    neovim
    nushell
    wget
    zsh
  ];
  environment.variables.EDITOR = "nvim";

  # `brew bundle` runs mid-activation, before home-manager. brew resolves the
  # store to $HOME/.homebrew/trust.json under the activation's `sudo
  # --user=amin --set-home`.
  system.activationScripts.preActivation.text = ''
    /usr/bin/install -d -o amin -g staff -m 0700 /Users/amin/.homebrew
    /usr/bin/install -o amin -g staff -m 0600 ${homebrewTrustStore} /Users/amin/.homebrew/trust.json
  '';

  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  #
  # The apps installed by homebrew are not managed by nix, and not reproducible!
  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = true;
      # 'zap': uninstalls all formulae(and related files) not listed here.
      # Disable if you want to keep ad-hoc installed formulae.
      cleanup = "zap";
      # zap cleanup non-interactively (HB 6 prompts otherwise)
      extraFlags = [ "--force-cleanup" ];
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = {
      Notability = 360593530;
      Vimlike = 1584519802;
    };
    taps = [ ];
    brews = [
      "acsandmann/tap/rift"
      "clang-format"
      "docker-credential-helper"
      "dust"
      "mas"
      "multitail"
      "node"
      "typescript"
      "zstd"
    ];
    casks = [
      "1password"
      "1password-cli"
      "chatgpt"
      "claude"
      "cloudflare-warp"
      "contexts"
      "docker-desktop"
      "ghostty"
      "google-chrome"
      "granola"
      "iterm2"
      "itermai"
      "karabiner-elements"
      "logi-options+"
      "maccy"
      "monitorcontrol"
      "notion"
      "raycast"
      "stats"
      "telegram"
      "whatsapp"
      "zed"
      "zoom"
    ];
  };
}

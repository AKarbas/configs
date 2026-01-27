{ pkgs, ... }:
{
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    curl
    git
    neovim
    nushell
    tailscale
    wget
    zsh
  ];
  environment.variables.EDITOR = "nvim";
  services.tailscale.enable = true;

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
    };

    # Applications to install from Mac App Store using mas.
    # You need to install all these Apps manually first so that your apple account have records for them.
    # otherwise Apple Store will refuse to install them.
    # For details, see https://github.com/mas-cli/mas
    masApps = { };
    taps = [ ];
    brews = [
      "acsandmann/tap/rift"
      "clang-format"
      "docker-credential-helper"
      "dust"
      "node"
      "typescript"
      "zstd"
    ];
    casks = [
      "aws-vpn-client"
      "chatgpt"
      "cloudflare-warp"
      "docker-desktop"
      "firefox"
      "ghostty"
      "google-chrome"
      "iglance"
      "iina"
      "iterm2"
      "itermai"
      "itermbrowserplugin"
      "karabiner-elements"
      "linear-linear"
      "logi-options+"
      "maccy"
      "pgadmin4"
      "postman"
      "raycast"
      "rectangle"
      "superhuman"
      "visual-studio-code"
      "webstorm"
      "zed"
      "zoom"
    ];
  };
}

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
      "chatgpt"
      "claude"
      "cloudflare-warp"
      "contexts"
      "docker-desktop"
      "ghostty"
      "google-chrome"
      "iglance"
      "iterm2"
      "itermai"
      "karabiner-elements"
      "logi-options+"
      "maccy"
      "monitorcontrol"
      "notion"
      "raycast"
      "rectangle"
      "telegram"
      "whatsapp"
      "zed"
      "zoom"
    ];
  };
}

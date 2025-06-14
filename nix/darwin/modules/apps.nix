{
  pkgs,
  ...
}:
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
    };
    taps = [
      "homebrew/services"
      "ngrok/ngrok"
      "robusta-dev/holmesgpt"
    ];
    brews = [
      "clang-format"
      "docker-credential-helper"
      "holmesgpt"
      #"spr" # more up-to-date than nixpkgs - currently broken (v1.3.6)
      "zstd"
    ];
    casks = [
      "aws-vpn-client"
      "chatgpt"
      "cloudflare-warp"
      # docker-for-mac vesrion 4.42.0 is broken - manually installed 4.41.2 via DMG file.
      # https://github.com/docker/for-mac/issues/7693
      # https://desktop.docker.com/mac/main/arm64/191736/Docker.dmg
      #"docker"
      "firefox"
      "github"
      "google-chrome"
      "headlamp"
      "iglance"
      "iterm2"
      "itermai"
      "karabiner-elements"
      "keymapp"
      "linear-linear"
      "maccy"
      "ngrok"
      "openinterminal-lite"
      "postman"
      "raycast"
      "rectangle"
      "thelowtechguys-cling"
      "thunderbird"
      "visual-studio-code"
      "zed"
      "zoom"
    ];
  };
}

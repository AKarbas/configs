{pkgs, ...}: {
  # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
  environment.systemPackages = with pkgs; [
    neovim
    git
    tailscale
  ];
  environment.variables.EDITOR = "nvim";
  services.tailscale.enable = true;

  # No homebrew unless absolutely necessary.
  #  # TODO To make this work, homebrew need to be installed manually, see https://brew.sh
  #  #
  #  # The apps installed by homebrew are not managed by nix, and not reproducible!
  #  # But on macOS, homebrew has a much larger selection of apps than nixpkgs, especially for GUI apps!
  #  homebrew = {
  #    enable = true;
  #
  #    onActivation = {
  #      autoUpdate = false;
  #      # 'zap': uninstalls all formulae(and related files) not listed here.
  #      cleanup = "zap";
  #    };
  #
  #    # Applications to install from Mac App Store using mas.
  #    # You need to install all these Apps manually first so that your apple account have records for them.
  #    # otherwise Apple Store will refuse to install them.
  #    # For details, see https://github.com/mas-cli/mas
  #    masApps = {
  #    };
  #    taps = [
  #      "homebrew/cask"
  #      "homebrew/cask-fonts"
  #      "homebrew/services"
  #      "homebrew/cask-versions"
  #    ];
  #    brews = [
  #    ];
  #    casks = [
  #      "firefox"
  #      "google-chrome"
  #      "visual-studio-code"
  #      "telegram"
  #      "discord"
  #      "openinterminal-lite"
  #      #"raycast"
  #      "iglance"
  #    ];
  #  };
}

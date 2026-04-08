{ lib, ... }:
{
  # UNiCORN-specific apps. Move items from apps-common.nix here as needed.
  system.defaults.dock.persistent-apps = lib.mkForce [
    "/System/Applications/Mail.app"
    "/System/Applications/Reminders.app"
    "/System/Applications/Music.app"
    "/System/Applications/iPhone Mirroring.app"
    "/Applications/Google Chrome.app"
    "/Applications/Slack.app"
    "/System/Applications/Messages.app"
    "/System/Applications/Calendar.app"
  ];
  homebrew = {
    brews = [ ];
    casks = [
      "aws-vpn-client"
      "firefox"
      "linear-linear"
      "pgadmin4"
      "postman"
      "slack"
      "visual-studio-code"
    ];
    masApps = { };
  };
}

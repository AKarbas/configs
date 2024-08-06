{pkgs, ...}:
###################################################################################
#
#  macOS's System configuration
#
#  All the configuration options are documented here:
#    https://daiderd.com/nix-darwin/manual/index.html#sec-options
#  and see the source code of this project to get more undocumented options:
#    https://github.com/rgcr/m-cli
#
###################################################################################
{
  system = {
    activationScripts.postUserActivation.text = ''
      /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    '';
    defaults = {
      menuExtraClock = {
        ShowDate = 0; # true
        ShowSeconds = true;
        Show24Hour = true;
      };
      dock = {
        appswitcher-all-displays = true;
        autohide = true;
        largesize = 80;
        magnification = true;
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "right";
        show-process-indicators = true;
        show-recents = false;
        tilesize = 64;
        expose-animation-duration = 0.0;
        expose-group-by-app = true;
        launchanim = false;
      };
      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = true;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.sound.beep.volume" = 0.5;
        "com.apple.springing.enabled" = true;
        AppleICUForce24HourTime = true;
        AppleInterfaceStyle = "Dark";
        #AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        KeyRepeat = 2; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSWindowResizeTime = 0.0;
      };
      # Customize settings that not supported by nix-darwin directly
      # see the source code of this project to get more undocumented options:
      #    https://github.com/rgcr/m-cli
      #
      # All custom entries can be found by running `defaults read` command.
      # or `defaults read xxx` to read a specific domain.
      CustomUserPreferences = {
        ".GlobalPreferences" = {
          AppleSpacesSwitchOnActivate = true;
          AppleActionOnDoubleClick = "Minimize";
        };
        NSGlobalDomain = {
          WebKitDeveloperExtras = true;
        };
        "com.apple.finder" = {
          ShowExternalHardDrivesOnDesktop = true;
          ShowHardDrivesOnDesktop = true;
          ShowMountedServersOnDesktop = true;
          ShowRemovableMediaOnDesktop = true;
          _FXSortFoldersFirst = true;
          # When performing a search, search the current folder by default
          #FXDefaultSearchScope = "SCcf";
        };
        "com.apple.desktopservices" = {
          # Avoid creating .DS_Store files on network or USB volumes
          DSDontWriteNetworkStores = true;
          DSDontWriteUSBStores = true;
        };
        "com.apple.screensaver" = {
          # Require password immediately after sleep or screen saver begins
          askForPassword = 1;
          askForPasswordDelay = 0;
        };
        "com.apple.screencapture" = {
          location = "~/Desktop";
          type = "png";
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.ImageCapture".disableHotPlug = true;
      };
      loginwindow = {
        GuestEnabled = false;
        SHOWFULLNAME = true;
      };
    };
    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToControl = true;
    };
  };
  environment.shells = [
    pkgs.zsh
  ];
  fonts = {
    packages = with pkgs; [
      material-design-icons
      font-awesome
      (nerdfonts.override {
        fonts = [
          "FiraCode"
        ];
      })
    ];
  };
  programs.zsh.enable = true;
  security.pam.enableSudoTouchIdAuth = true;
  # Set your time zone.
  # comment this due to the issue:
  #   https://github.com/LnL7/nix-darwin/issues/359
  # time.timeZone = "Asia/shanghai";
}

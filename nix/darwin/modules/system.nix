{ pkgs, ... }:
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
  # Fix for nixbld group GID mismatch
  ids.gids.nixbld = 30000;

  system = {
    stateVersion = 5;
    defaults = {
      menuExtraClock = {
        ShowDate = 0; # true
        ShowSeconds = true;
        Show24Hour = true;
        ShowDayOfWeek = true;
        ShowDayOfMonth = true;
      };
      dock = {
        appswitcher-all-displays = true;
        autohide = true;
        autohide-delay = 0.0;
        autohide-time-modifier = 0.15;
        largesize = 80;
        magnification = true;
        minimize-to-application = true;
        mru-spaces = false;
        orientation = "right";
        persistent-apps = [
          "/System/Applications/Mail.app"
          "/System/Applications/Reminders.app"
          "/System/Applications/Music.app"
          "/System/Applications/iPhone Mirroring.app"
          "/Applications/Google Chrome.app"
          "/System/Applications/Messages.app"
          "/System/Applications/Calendar.app"
        ];
        persistent-others = [ ];
        show-process-indicators = true;
        show-recents = false;
        tilesize = 64;
        expose-animation-duration = 0.0;
        expose-group-apps = false; # used to be true - testing
        launchanim = false;
        wvous-tl-corner = 1; # disabled
        wvous-tr-corner = 1;
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
      };
      controlcenter = {
        BatteryShowPercentage = true;
        Sound = true;
      };
      finder = {
        _FXShowPosixPathInTitle = true;
        AppleShowAllExtensions = true;
        AppleShowAllFiles = true;
        FXEnableExtensionChangeWarning = false;
        FXPreferredViewStyle = "Nlsv";
        QuitMenuItem = true;
        ShowPathbar = true;
        ShowStatusBar = true;
      };
      trackpad = {
        Clicking = true;
        TrackpadRightClick = true;
        TrackpadThreeFingerDrag = true;
      };
      WindowManager = {
        GloballyEnabled = false;
        EnableStandardClickToShowDesktop = true;
        EnableTiledWindowMargins = true;
        AppWindowGroupingBehavior = true;
        AutoHide = true;
      };
      universalaccess = {
        reduceMotion = true;
        reduceTransparency = false;
      };
      SoftwareUpdate = {
        AutomaticallyInstallMacOSUpdates = true;
      };
      spaces = {
        spans-displays = false;
      };
      NSGlobalDomain = {
        "com.apple.swipescrolldirection" = true;
        "com.apple.sound.beep.feedback" = 0;
        "com.apple.sound.beep.volume" = 0.5;
        "com.apple.springing.enabled" = true;
        "com.apple.keyboard.fnState" = false;
        AppleInterfaceStyleSwitchesAutomatically = true;
        AppleICUForce24HourTime = true;
        ApplePressAndHoldEnabled = false;
        AppleShowScrollBars = "WhenScrolling";
        InitialKeyRepeat = 15; # normal minimum is 15 (225 ms), maximum is 120 (1800 ms)
        KeyRepeat = 2; # normal minimum is 2 (30 ms), maximum is 120 (1800 ms)
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSDocumentSaveNewDocumentsToCloud = false;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSTableViewDefaultSizeMode = 2;
        NSWindowResizeTime = 0.0;
        PMPrintingExpandedStateForPrint = true;
        PMPrintingExpandedStateForPrint2 = true;
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
        "com.apple.symbolichotkeys" = {
          AppleSymbolicHotKeys = {
            # Spotlight: disabled (Raycast replaces it)
            "60" = {
              enabled = 0;
              value = {
                parameters = [
                  32
                  49
                  262144
                ];
                type = "standard";
              };
            };
            # Input source switch: Opt+Cmd+Space
            "61" = {
              enabled = 1;
              value = {
                parameters = [
                  32
                  49
                  1572864
                ];
                type = "standard";
              };
            };
            # Input Sources: all disabled
            "15" = {
              enabled = 0;
            };
            "16" = {
              enabled = 0;
            };
            "17" = {
              enabled = 0;
            };
            "18" = {
              enabled = 0;
            };
            "19" = {
              enabled = 0;
            };
            "20" = {
              enabled = 0;
            };
            "21" = {
              enabled = 0;
            };
            "22" = {
              enabled = 0;
            };
            "23" = {
              enabled = 0;
            };
            "24" = {
              enabled = 0;
            };
            "25" = {
              enabled = 0;
            };
            "26" = {
              enabled = 0;
            };
            # Mission Control: Ctrl+\
            "32" = {
              enabled = 1;
              value = {
                parameters = [
                  92
                  42
                  262144
                ];
                type = "standard";
              };
            };
            # Application Windows: Ctrl+Opt+\
            "33" = {
              enabled = 1;
              value = {
                parameters = [
                  92
                  42
                  786432
                ];
                type = "standard";
              };
            };
            # Show Desktop: Shift+Ctrl+\
            "34" = {
              enabled = 1;
              value = {
                parameters = [
                  92
                  42
                  393216
                ];
                type = "standard";
              };
            };
            # Show Desktop (variant): Shift+Ctrl+Opt+\
            "35" = {
              enabled = 1;
              value = {
                parameters = [
                  92
                  42
                  917504
                ];
                type = "standard";
              };
            };
            # Move focus to left display: disabled
            "36" = {
              enabled = 0;
            };
            # Move focus to right display: disabled
            "37" = {
              enabled = 0;
            };
            # Move left a space: Ctrl+[
            "79" = {
              enabled = 1;
              value = {
                parameters = [
                  91
                  33
                  262144
                ];
                type = "standard";
              };
            };
            # Move left a space + window: disabled
            "80" = {
              enabled = 0;
            };
            # Move right a space: Ctrl+]
            "81" = {
              enabled = 1;
              value = {
                parameters = [
                  93
                  30
                  262144
                ];
                type = "standard";
              };
            };
            # Move right a space + window: disabled
            "82" = {
              enabled = 0;
            };
            # Switch input source: disabled
            "65" = {
              enabled = 0;
              value = {
                parameters = [
                  32
                  49
                  1572864
                ];
                type = "standard";
              };
            };
            # Notification Center: Globe+N
            "164" = {
              enabled = 1;
              value = {
                parameters = [
                  110
                  45
                  8388608
                ];
                type = "standard";
              };
            };
            # Show Focus: Globe+F
            "176" = {
              enabled = 1;
              value = {
                parameters = [
                  102
                  3
                  8388608
                ];
                type = "standard";
              };
            };
            # Show Help menu: Shift+Cmd+/
            "98" = {
              enabled = 1;
              value = {
                parameters = [
                  47
                  44
                  1179648
                ];
                type = "standard";
              };
            };
            # Move focus to menu bar: disabled
            "118" = {
              enabled = 0;
            };
          };
        };
        "com.apple.driver.AppleBluetoothMultitouch.mouse" = {
          MouseButtonDivision = 55;
          MouseButtonMode = "TwoButton";
          MouseHorizontalScroll = 1;
          MouseMomentumScroll = 1;
          MouseOneFingerDoubleTapGesture = 1;
          MouseTwoFingerDoubleTapGesture = 3;
          MouseTwoFingerHorizSwipeGesture = 2;
          MouseVerticalScroll = 1;
        };
        "com.apple.screencapture" = {
          location = "~/Desktop";
          type = "png";
        };
        "com.apple.AdLib" = {
          allowApplePersonalizedAdvertising = false;
        };
        "com.apple.dock" = {
          showAppExposeGestureEnabled = true;
        };
        "com.apple.ImageCapture".disableHotPlug = true;
        "com.apple.AppleMultitouchTrackpad" = {
          TrackpadFourFingerVertSwipeGesture = 2;
          TrackpadFourFingerHorizSwipeGesture = 2;
          TrackpadFourFingerPinchGesture = 2;
        };
        "com.googlecode.iterm2" = {
          AlternateMouseScroll = true;
          HideMenuBarInFullscreen = true;
          StretchTabsToFillBar = true;
          FlashTabBarInFullscreen = true;
          QuitWhenAllWindowsClosed = true;
          HideTab = true;
          DimInactiveSplitPanes = false;
          AdjustWindowForFontSizeChange = false;
          PreventEscapeSequenceFromClearingHistory = true;
          RestoreWindowsToSameSpaces = true;
          AutoCommandHistory = true;
          TabStyleWithAutomaticOption = 1;
          TabViewType = 0;
          AppleWindowTabbingMode = "manual";
          UseLionStyleFullscreen = false;
          NeverBlockSystemShutdown = true;
          AlwaysOpenWindowAtStartup = true;
          SavePasteHistory = true;
          StatusBarPosition = 1;
          WordCharacters = "/-+\\~_.";
          PasteTabToStringTabStopSize = 4;
          ConvertDosNewlines = false;
          SoundForEsc = false;
          HapticFeedbackForEsc = false;
        };
        "com.contextsformac.Contexts" = {
          CTPreferenceInputDoubleTouchSwitchGestureActive = 1;
          CTPreferencePanelRecentSwitcherShowAfterDelay = 0;
          CTPreferenceRecentItemsSwitcherSearchEnabled = 1;
          CTPreferenceSearchShortcutCommandLeftKeyEnabled = 0;
          CTPreferenceSearchShortcutFunctionKeyEnabled = 0;
          CTPreferenceSearchShortcutMaxLength = 3;
          CTPreferenceSearchShortcutOptionLeftKeyEnabled = 0;
          CTPreferenceSidebarDisplayMode = "CTDisplayModeAllScreens";
          CTPreferenceSidebarShowDockIconStatus = 1;
          CTPreferenceSidebarSpacesOption = "CTSpacesOptionAll";
          CTPreferenceWorkspaceConstrainWindowFrames = 1;
          CTSidebarHorizontalAlignment = "CTWindowHorizontalAlignmentRight";
          CTSidebarInactiveMaximumWidth = 1;
          CTSidebarShowIndicesForWindows = 0;
          CTKeyboardEventCommandModeActive = 0;
          CTKeyboardEventLeftCommandNumberActive = 0;
        };
        "com.knollsoft.Rectangle" = {
          allowAnyShortcut = 1;
          alternateDefaultShortcuts = 1;
          hideMenubarIcon = 1;
          launchOnLogin = 1;
          hapticFeedbackOnSnap = 1;
          moveCursorAcrossDisplays = 1;
          footprintAnimationDurationMultiplier = "0.75";
          subsequentExecutionMode = 0;
          unsnapRestore = 2;
          windowSnapping = 2;
          almostMaximize = {
            keyCode = 3;
            modifierFlags = 786432;
          };
          nextDisplay = {
            keyCode = 30;
            modifierFlags = 1835008;
          };
          previousDisplay = {
            keyCode = 33;
            modifierFlags = 1835008;
          };
          reflowTodo = {
            keyCode = 45;
            modifierFlags = 786432;
          };
          toggleTodo = {
            keyCode = 11;
            modifierFlags = 786432;
          };
          todo = 2;
          bottomHalf = { };
          bottomLeft = { };
          bottomRight = { };
          centerHalf = { };
          centerThird = { };
          firstThird = { };
          firstTwoThirds = { };
          larger = { };
          lastThird = { };
          lastTwoThirds = { };
          leftHalf = { };
          maximize = { };
          maximizeHeight = { };
          restore = { };
          rightHalf = { };
          smaller = { };
          topHalf = { };
          topLeft = { };
          topRight = { };
        };
        "com.raycast.macos" = {
          raycastGlobalHotkey = "Control-Option-49";
          raycastPreferredWindowMode = "default";
          raycastShouldFollowSystemAppearance = 1;
          "raycastUI_preferredTextSize" = "medium";
          raycastWindowPresentationMode = 1;
          navigationCommandStyleIdentifierKey = "macos";
          useHyperKeyIcon = 0;
          showGettingStartedLink = 0;
        };
        "org.p0deje.Maccy" = {
          historySize = 999;
          searchMode = "fuzzy";
          popupPosition = "cursor";
          pinTo = "top";
          showInStatusBar = 0;
          showFooter = 0;
          showTitle = 0;
          showRecentCopyInMenuBar = 0;
          showSearch = 1;
          showSpecialSymbols = 1;
          showApplicationIcons = 1;
          imageMaxHeight = 40;
          menuIcon = "maccy";
          previewDelay = 200;
          searchVisibility = "duringSearch";
          ignoreEvents = 0;
          sortBy = "lastCopiedAt";
          enabledPasteboardTypes = [
            "public.utf8-plain-text"
            "public.rtf"
            "public.png"
            "public.tiff"
            "public.html"
            "public.file-url"
          ];
          KeyboardShortcuts_popup = "{\"carbonKeyCode\":9,\"carbonModifiers\":6144}";
          KeyboardShortcuts_pin = "{\"carbonModifiers\":2048,\"carbonKeyCode\":35}";
          KeyboardShortcuts_delete = "{\"carbonKeyCode\":51,\"carbonModifiers\":2304}";
        };
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
  # Using Determinate's nix distribution doesn't allow NixDarwin to manage nix.
  nix.enable = false;
  environment.shells = with pkgs; [
    nushell
    zsh
  ];
  fonts = {
    packages = with pkgs; [
      material-design-icons
      font-awesome
      nerd-fonts.fira-code
    ];
  };
  programs.zsh.enable = true;
  security.pam.services.sudo_local.touchIdAuth = true;
  security.pam.services.sudo_local.watchIdAuth = true;
  power = {
    sleep = {
      computer = "never";
      display = 10;
    };
  };
  system.activationScripts.postActivation.text = ''
    sudo -u amin /System/Library/PrivateFrameworks/SystemAdministration.framework/Resources/activateSettings -u
    # Clean up old brew-managed rift launch agent if present
    if [ -f /Users/amin/Library/LaunchAgents/git.acsandmann.rift.plist ]; then
      sudo -u amin launchctl bootout "gui/$(id -u amin)" /Users/amin/Library/LaunchAgents/git.acsandmann.rift.plist 2>/dev/null || true
      rm -f /Users/amin/Library/LaunchAgents/git.acsandmann.rift.plist
    fi
  '';
  launchd.user.agents.rift = {
    serviceConfig = {
      ProgramArguments = [ "/opt/homebrew/bin/rift" ];
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
        Crashed = true;
      };
      EnvironmentVariables = {
        PATH = "/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin";
        RUST_LOG = "error,warn,info";
      };
      StandardOutPath = "/tmp/rift_amin.out.log";
      StandardErrorPath = "/tmp/rift_amin.err.log";
      ProcessType = "Interactive";
      LimitLoadToSessionType = "Aqua";
      Nice = -20;
    };
  };
  # Set your time zone.
  # comment this due to the issue:
  #   https://github.com/LnL7/nix-darwin/issues/359
  # time.timeZone = "Asia/shanghai";
}

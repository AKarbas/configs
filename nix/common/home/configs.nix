{
  config,
  lib,
  pkgs,
  ...
}:
{
  # `programs.git` will generate the config file: ~/.config/git/config
  # to make git use this config file, `~/.gitconfig` should not exist!
  #
  #    https://git-scm.com/docs/git-config#Documentation/git-config.txt---global
  home.activation.removeExistingGitconfig = lib.hm.dag.entryBefore [ "checkLinkTargets" ] ''
    rm -f ~/.gitconfig
  '';
  home.activation.copyKarabinerConfig = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config/karabiner"
      cp -f "${./dotfiles/karabiner/karabiner.json}" "$HOME/.config/karabiner/karabiner.json"
      chmod 644 "$HOME/.config/karabiner/karabiner.json"
    ''
  );
  home.activation.copyZedConfig = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config/zed"
      cp -f "${./dotfiles/zed/settings.json}" "$HOME/.config/zed/settings.json"
      cp -f "${./dotfiles/zed/keymap.json}" "$HOME/.config/zed/keymap.json"
      chmod 644 "$HOME/.config/zed/settings.json" "$HOME/.config/zed/keymap.json"
    ''
  );

  home.activation.configureITerm = lib.mkIf pkgs.stdenv.isDarwin (
    lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      PLIST="$HOME/Library/Preferences/com.googlecode.iterm2.plist"
      PB=/usr/libexec/PlistBuddy

      if [ ! -f "$PLIST" ]; then
        $PB -c "Save" "$PLIST" 2>/dev/null
      fi

      $PB -c "Print :New\ Bookmarks:0:Guid" "$PLIST" &>/dev/null || {
        $PB -c "Delete :New\ Bookmarks" "$PLIST" &>/dev/null || true
        $PB -c "Add :New\ Bookmarks array" "$PLIST"
        $PB -c "Add :New\ Bookmarks:0 dict" "$PLIST"
      }

      pb() {
        $PB -c "Set :New\ Bookmarks:0:$1 $3" "$PLIST" 2>/dev/null || \
          $PB -c "Add :New\ Bookmarks:0:$1 $2 $3" "$PLIST"
      }

      pb "Guid"                                               string  "amin-iterm-profile-0001"
      pb "Name"                                               string  "amin"
      pb "Default\ Bookmark"                                  string  "No"
      pb "Normal\ Font"                                       string  "FiraCodeNFM-Reg 11"
      pb "Terminal\ Type"                                     string  "xterm-256color"
      pb "Custom\ Directory"                                  string  "Recycle"
      pb "Working\ Directory"                                 string  "/Users/amin"
      pb "Blinking\ Cursor"                                   bool    true
      pb "Unlimited\ Scrollback"                              bool    true
      pb "Scrollback\ Lines"                                  integer 0
      pb "ASCII\ Ligatures"                                   bool    true
      pb "Visual\ Bell"                                       bool    true
      pb "Mouse\ Reporting"                                   bool    true
      pb "Show\ Status\ Bar"                                  bool    true
      pb "Prompt\ Before\ Closing\ 2"                         bool    false
      pb "Use\ Separate\ Colors\ for\ Light\ and\ Dark\ Mode" bool true
      pb "Transparency"                                       real    0.196211
      pb "Blur"                                               bool    true
      pb "Blur\ Radius"                                       real    15.120991

      # Natural Text Editing keyboard map
      $PB -c "Delete :New\ Bookmarks:0:Keyboard\ Map" "$PLIST" 2>/dev/null || true
      $PB -c "Add :New\ Bookmarks:0:Keyboard\ Map dict" "$PLIST"
      km() { # km <hexkey> <action> <text>
        $PB -c "Add :New\ Bookmarks:0:Keyboard\ Map:$1 dict" "$PLIST"
        $PB -c "Add :New\ Bookmarks:0:Keyboard\ Map:$1:Action integer $2" "$PLIST"
        $PB -c "Add :New\ Bookmarks:0:Keyboard\ Map:$1:Text string $3" "$PLIST"
      }
      km "0xf702-0x280000" 10 "b"            # Opt+Left       → word backward
      km "0xf703-0x280000" 10 "f"            # Opt+Right      → word forward
      km "0xf702-0x300000" 11 "0x1"          # Cmd+Left       → line start
      km "0xf703-0x300000" 11 "0x5"          # Cmd+Right      → line end
      km "0x7f-0x80000"    11 "0x1b 0x7f"    # Opt+Delete     → delete word backward
      km "0x7f-0x100000"   11 "0x15"         # Cmd+Delete     → delete line
      km "0xf728-0x80000"  10 "d"            # Opt+Fn+Delete  → delete word forward
      km "0xf728-0x0"      11 "0x4"          # Fn+Delete      → delete char forward

      # Status bar layout (components: CPU, Memory, Network, Job, Clock, Battery, Working Dir)
      $PB -c "Delete :New\ Bookmarks:0:Status\ Bar\ Layout" "$PLIST" 2>/dev/null || true
      $PB -c "Add :New\ Bookmarks:0:Status\ Bar\ Layout dict" "$PLIST"
      $PB -c "Merge ${./dotfiles/iterm2/status-bar-layout.plist} :New\ Bookmarks:0:Status\ Bar\ Layout" "$PLIST"

      $PB -c "Set :Default\ Bookmark\ Guid amin-iterm-profile-0001" "$PLIST" 2>/dev/null || \
        $PB -c "Add :Default\ Bookmark\ Guid string amin-iterm-profile-0001" "$PLIST"
    ''
  );
  programs = {
    home-manager.enable = true;
    git = {
      enable = true;
      lfs.enable = true;
      userName = "Amin Karbas";
      userEmail = "6280244+AKarbas@users.noreply.github.com";
      extraConfig = {
        init.defaultBranch = "main";
        push.autoSetupRemote = true;
        advice.detachedHead = false;
        advice.skippedCherryPicks = false;
        core.logallrefupdates = true;
        core.autocrlf = false;
        core.untrackedcache = true;
        core.fsmonitor = true;
        http.postBuffer = 1024 * 1024 * 1024;
      };
    };
    starship = {
      enable = true;
      enableZshIntegration = true;
      settings = {
        character = {
          error_symbol = "[✗](bold red)";
        };
        cmd_duration = {
          min_time = 0;
          show_milliseconds = true;
        };
        directory = {
          fish_style_pwd_dir_length = 3;
        };
        direnv = {
          disabled = false;
          format = "[$symbol($loaded$allowed)](bold white) ";
          allowed_msg = "✔";
          denied_msg = "✗";
          not_allowed_msg = "🔘";
          loaded_msg = "";
        };
        git_branch = {
          disabled = true;
        };
        git_commit = {
          only_detached = false;
          tag_disabled = false;
          disabled = true;
        };
        git_state = {
          disabled = true;
        };
        git_metrics = {
          disabled = true;
        };
        git_status = {
          disabled = true;
        };
        kubernetes = {
          disabled = false;
        };
        sudo = {
          disabled = false;
        };
        time = {
          disabled = false;
          utc_time_offset = "0";
          time_format = "%T%.3f";
          format = "[$time]($style)";
        };
      };
    };
    ssh = {
      enable = true;
      includes = [ "config.d/*" ];
      addKeysToAgent = "yes";
      matchBlocks."*" = {
        extraOptions.UseKeychain = "yes";
        identityFile = [ "~/.ssh/id_ed25519" ];
      };
    };
    neovim = {
      enable = true;
      defaultEditor = true;
      vimAlias = true;
      extraConfig = ''
        set number
      '';
    };
    # A modern replacement for ‘ls’
    # useful in bash/zsh prompt, not in nushell.
    eza = {
      enable = true;
      enableZshIntegration = true;
      git = true;
    };
    atuin = {
      enable = true;
      enableNushellIntegration = true;
      enableZshIntegration = true;
      # This does not work if a config for atuin already exists
      # https://github.com/nix-community/home-manager/issues/5734
      settings = {
        enter_accept = false;
        search_mode = "fuzzy";
      };
    };
    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    ghostty = {
      enable = true;
      package = null; # installed via homebrew cask
      settings = {
        auto-update = "check";
        background-blur = 20;
        background-opacity = 0.9;
        copy-on-select = "clipboard";
        font-family = "FiraCode Nerd Font Mono";
        keybind = [
          "ctrl+alt+h=goto_split:left"
          "ctrl+alt+j=goto_split:down"
          "ctrl+alt+k=goto_split:up"
          "ctrl+alt+l=goto_split:right"
          "global:cmd+;=toggle_quick_terminal"
          "super+ctrl+h=resize_split:left,10"
          "super+ctrl+j=resize_split:down,10"
          "super+ctrl+k=resize_split:up,10"
          "super+ctrl+l=resize_split:right,10"
        ];
        macos-non-native-fullscreen = "visible-menu";
        macos-titlebar-style = "tabs";
        quick-terminal-animation-duration = 0;
        scrollback-limit = 1024 * 1024 * 1024;
        shell-integration-features = "ssh-terminfo";
        theme = "Mathias";
        unfocused-split-fill = "#302e33";
        window-padding-x = 4;
        window-padding-y = 4;
      };
    };
    jujutsu = {
      enable = true;
      settings = {
        user = {
          name = "Amin Karbas";
          email = "6280244+AKarbas@users.noreply.github.com";
        };
        git = {
          private-commits = "description(glob:'*local-only*')";
          push-bookmark-prefix = "amin/push-";
        };
        templates.git_push_bookmark = ''"amin/push-" ++ change_id.short()'';
        aliases.spr = [
          "util"
          "exec"
          "--"
          "jj-spr"
        ];
      };
    };
    zsh = {
      autocd = true;
      autosuggestion.enable = true;
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        "ja!" = "jj abandon";
        cdjr = "cd $(jj root)";
        ghpr = "gh pr list --author=@me --json url,title | jq -r 'reverse | .[] | \"[\" + .title + \"](\" + .url + \")\"'";
        ghprd = "gh pr list --author=@me --json url,title | jq -r 'reverse | .[] | \"- [\" + .title + \"](\" + .url + \")\"'";
        grboma = "git rebase origin/$(git_main_branch) --autosquash";
        gsh = "git show --stat --patch";
        jab = "jj absorb";
        jbd = "jj --no-pager bookmark delete";
        jbl = "jj --no-pager bookmark list";
        jblc = "jj --no-pager bookmark list --conflicted";
        jci = "jj commit -i";
        jd = "jj diff";
        jds = "jj describe";
        jds- = "jj describe @-";
        jgp = "jj git push";
        jgp- = "jj git push -c @-";
        jgpa = "jj git push --all --deleted";
        jgpb = "jj git push -b";
        jl = "jj log";
        jla = "jj log -r 'all()'";
        jlm = "jj log -r 'mine() & ~(::remote_bookmarks(glob:\"*spr/*\"))'";
        jrb = "jj rebase";
        jrb- = "jj rebase -s @- -d";
        jrbom = "jj git fetch && jj rebase --skip-emptied -d main@origin";
        jsh = "jj show";
        jsh- = "jj show @-";
        jsi = "jj squash -i";
        jst = "jj --no-pager status";
        jwl = "jj workspace list";
        jwu = "jj workspace update-stale";
        l = "ls -ahl";
        sd = "git-spr-single diff";
        sl = "git-spr-single land";
        tf = "terraform";
        tg = "terragrunt";
      };
      initContent = ''
        source ${./scripts/jj-workspaces.zsh}
      '';
      oh-my-zsh = {
        enable = true;
        plugins = [
          "aws"
          "docker"
          "git"
          "kubectl"
          "kubectx"
          "macos"
          "z"
        ];
        extraConfig = ''
          DISABLE_FZF_KEY_BINDINGS="true"
          export ZVM_INIT_MODE=sourcing
          bindkey '^r' _atuin_search_widget
        '';
      };
      plugins = [
        {
          name = "zsh-vi-mode";
          src = "${pkgs.zsh-vi-mode}/share/zsh-vi-mode";
        }
        {
          name = "fzf-tab";
          src = "${pkgs.zsh-fzf-tab}/share/fzf-tab";
        }
      ];
    };
  };
  home = {
    username = "amin";
    homeDirectory = if pkgs.stdenv.isLinux then "/home/amin" else "/Users/amin";
    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "24.11";
    sessionPath = [
      "/opt/homebrew/bin/"
      "${config.home.homeDirectory}/go/bin/"
      "/Applications/Docker.app/Contents/Resources/bin"
      "${config.home.homeDirectory}/.npm-global/bin"
    ];
    sessionVariables = {
      KUBECONFIG = "${config.home.homeDirectory}/.kube/config";
      npm_config_prefix = "${config.home.homeDirectory}/.npm-global";
    };
    file = {
      ".config/rift/config.toml" = lib.mkIf pkgs.stdenv.isDarwin {
        source = ./dotfiles/rift/config.toml;
      };
    };
  };
}

{pkgs, ...}: {
  home.packages = with pkgs; [
    age
    awscli2
    axel
    bat
    bazel-buildtools
    bazel_7
    btop
    buf-language-server
    clang-tools
    cmake
    colima
    colordiff
    deno
    direnv
    docker-client
    file
    fzf
    gawk
    gh
    gnumake
    gnupg
    gnused
    gnutar
    go
    htop-vim
    hugo
    jdk
    jq
    k6
    k9s
    kns
    krew
    kubectl
    kubectl-explore
    kubernetes-helm
    kubernetes-helmPlugins.helm-diff
    kubie
    mtr
    ninja
    nix
    nix-index
    nodePackages.nodemon
    nodePackages.ts-node
    nodejs
    p7zip
    parallel
    poetry
    postgresql
    python313
    restic
    ripgrep
    rsync
    rustup
    sbt
    skaffold
    spr
    sshuttle
    terraform
    terragrunt
    texlive.combined.scheme-full
    tmux
    tree
    typescript
    unzip
    uutils-coreutils
    watch
    watchman
    wget
    which
    wireguard-go
    wireguard-tools
    xz
    yamllint
    yq-go
    zip
    zsh
    zsh-autocomplete
    zsh-completions
    zsh-fast-syntax-highlighting
    zsh-fzf-tab
    zsh-z
    zstd
    (pkgs.writeShellScriptBin "git-spr-single" ''
      #!/bin/bash
      # Creds: gh:philz

      set -e -u -o pipefail

      # Ensure command argument is provided
      if [[ $# -lt 1 ]]; then
        echo "Usage: $0 <command: diff | land> [commit]"
        exit 1
      fi

      command=$1

      # Check if the command is valid
      if [[ "$command" != "diff" && "$command" != "land" ]]; then
        echo "Error: Command must be either 'diff' or 'land'."
        exit 1
      fi

      # Determine the commit
      merge_base=$(git merge-base HEAD origin/main)
      if [[ $# -eq 2 ]]; then
        commit_hash=$(git rev-parse "$2")
      else
        commit=$(git log --oneline $merge_base..HEAD | fzf --layout=reverse-list --height 80% --prompt "Select commit:" --preview "git show {1}")
        [[ -n "$commit" ]]
        commit_hash=$(echo $commit | awk '{print $1}')
      fi

      # Choose the correct spr command based on the provided command
      if [[ "$command" = "diff" ]]; then
              spr_command="spr $command --update-message"
      else
              spr_command="spr $command"
      fi

      # Perform interactive rebase with the selected or provided commit
      GIT_SEQUENCE_EDITOR="perl -i -pe 's/^(pick $commit_hash.*)$/\$1\\nexec $spr_command --cherry-pick /'" git rebase -i $merge_base
    '')
    (pkgs.writeShellScriptBin "git-vimdiff" ''
      #!/bin/bash
      # Creds: gh:philz
      #
      # Wrapper around git diff that accumulates changes,
      # and then calls vim in diff mode on all the changes.
      # Unlike gitdifftool, it invokes vim on all the files in
      # one go, thereby enabling navigation across all pairs
      # of files.
      #
      # Based on a hack by John Reese (jtr@google.com).
      #
      # See http://www.kernel.org/pub/software/scm/git/docs/git.html (GIT_EXTERNAL_DIFF)

      set -e

      # Writes vimdiff rc to temp directory.  All in an effort to keep this shell
      # script self-contained.
      function writerc {
        cat >$DIFFDIR/rc <<'ENDRC'
      " Color scheme fix:
      highlight DiffAdd    ctermbg=White
      highlight DiffChange    ctermbg=White
      highlight DiffText ctermbg=Yellow

      " Given two open panes, turn on diff mode " and leave the cursor on the left.
      " The left one is always the original, so it's set readonly
      fun! Diffball()
        " help |window-move-cursor| explain these
        wincmd w
        if expand("%") == "null"
          wincmd w | diffthis | set nofoldenable foldcolumn=0
          normal <c-w>_
        else
          wincmd t | diffthis | set nofoldenable foldcolumn=0 readonly
          wincmd w | diffthis | set nofoldenable foldcolumn=0
          normal ]c  " go to first change
        endif
      "  wincmd t
      "  goto 1
      endf

      " Go back to the beginning of the list of file pairs.
      fun! Diffrewind()
        only | set nodiff | rewind | set equalalways | vsplit
        wincmd w | next
        call Diffball()
      endf

      " Step to the next pair of files and diff them.
      fun! Diffnext()
        wincmd t | set nodiff | 2next
        wincmd w | set nodiff | 2next
        call Diffball()
      endf

      " Step to the previous pair of files and diff them.
      fun! Diffprev()
        wincmd t | set nodiff | 2prev
        wincmd w | set nodiff | 2prev
        call Diffball()
      endf

      fun! Diffquit()
        only | q!
      endf

      call Diffrewind()

      " Bind control-n to next and control-a to rewind.
      map <c-n> <c-[>:call Diffnext()<cr>
      map <c-p> <c-[>:call Diffprev()<cr>
      map <c-a> <c-[>:call Diffrewind()<cr>
      map <c-q> <c-[>:call Diffquit()<cr>
      ENDRC
      }

      function main {
        export TMPDIR=/''${TMPDIR:-/tmp}
        export DIFFDIR=$(mktemp -d $TMPDIR/git-vimdiff.XXXXXX)
        export GIT_VIMDIFF_HELPER=true
        GIT_EXTERNAL_DIFF="$0" git diff $*

        if [ -f $DIFFDIR/args ]; then
          GIT_ROOT=$(git rev-parse --show-cdup)
          if [ ! -z $GIT_ROOT ]; then
            cd $GIT_ROOT
          fi
          writerc
          vim -S $DIFFDIR/rc $(cat $DIFFDIR/args)
        fi
      }

      # Invoked on every set of changed files.  The
      # "old" file is copied to a temp directory and
      # made read-only.  The new file is copied to
      # a temp directory only if it's different
      # than the current copy.
      function helper {
        GIT_PATH=/''${GIT_ROOT}/''${1}
        OLD_FILE=$2
        OLD_HEX=$3
        OLD_MODE=$4
        NEW_FILE=$5
        NEW_MODE=$6

        mkdir -p $DIFFDIR/files
        # Make a temp dir so that all old file copies are unique.
        OUT_DIR=$(mktemp -d $DIFFDIR/files.XXXXXX)
        COPY_OF_OLD_FILE=$OUT_DIR/$(basename $GIT_PATH)
        cp $OLD_FILE $COPY_OF_OLD_FILE
        LEFT=$COPY_OF_OLD_FILE

        chmod ugo-w $COPY_OF_OLD_FILE
        if [ $GIT_PATH = $NEW_FILE ]; then
          RIGHT=$NEW_FILE
        else
          if diff -q $GIT_PATH $NEW_FILE; then
            RIGHT=$GIT_PATH
          else
            COPY_OF_NEW_FILE=$OUT_DIR/right-$(basename $GIT_PATH)
            cp $NEW_FILE $COPY_OF_NEW_FILE
            RIGHT=$COPY_OF_NEW_FILE
          fi
        fi

        # Accumulate the arguments for diff.
        echo $LEFT $RIGHT >> $DIFFDIR/args
      }

      if [ $GIT_VIMDIFF_HELPER ]; then
        helper "$@"
      else
        main "$@"
      fi
    '')
  ];

  programs = {
    # modern vim
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
    # skim provides a single executable: sk.
    # Basically anywhere you would want to use grep, try sk instead.
    skim = {
      enable = true;
      enableBashIntegration = true;
    };
  };
}

# JJ Multi-Workspace Workflow — Sourced in ../configs.nix

export JJ_WORKSPACES_DIR="${JJ_WORKSPACES_DIR:-$HOME/.jj-workspaces}"

# Remove all non-default workspaces
jwclean() {
    echo "Remove all workspaces? (y/N)"
    read -r confirm
    if [[ "$confirm" == "y" ]]; then
        for ws in $(jj workspace list | awk '{print $1}' | grep -v '^default$'); do
            jwd "$ws"
        done
    fi
}

# Delete workspace
jwd() {
    local name="$1"

    if [[ -z "$name" ]]; then
        echo "Usage: jwd <name>"
        return 1
    fi

    local ws_path=$(_jj_ws_path "$name")

    jj workspace forget "$name" 2>/dev/null

    if [[ -d "$ws_path" ]]; then
        rm -rf "$ws_path"
        echo "Removed: $name"
    fi
}

# cd into workspace
jwgo() {
    local name="$1"

    if [[ -z "$name" ]]; then
        jj workspace list
        return 1
    fi

    local ws_path=$(_jj_ws_path "$name")

    if [[ ! -d "$ws_path" ]]; then
        echo "Not found: $ws_path"
        jj workspace list
        return 1
    fi

    cd "$ws_path"
    jj st
}

# Print usage for all jj workspace functions
jwh() {
    cat <<'EOF'
jwa <name> [rev]       Create workspace (default: @)
jwaz <name> [rev]      Create workspace + open Zed
jwd <name>             Delete workspace
jwgo <name>            cd into workspace
jwh                    Show this help
jwpr <id> [branch]     Create pr-<id> workspace (fetches if branch given)
jwzed <name>           Open workspace in Zed
jwclean                Remove all non-default workspaces
jwall                  Show all workspaces with current change
jrbomw                 Rebase on main + update all workspaces

Aliases (in shellAliases):
jwl                    jj workspace list
jwu                    jj workspace update-stale
EOF
}

# Quick workspace for PR/bugbot
jwpr() {
    local name="$1"
    local branch="${2:-}"

    if [[ -z "$name" ]]; then
        echo "Usage: jwpr <id> [branch]"
        return 1
    fi

    if [[ -n "$branch" ]]; then
        jj git fetch
        jwaz "pr-$name" "$branch@origin"
    else
        jwaz "pr-$name"
    fi
}

# Create workspace + open Zed
jwaz() {
    jwa "$1" "${2:-@}" && jwzed "$1"
}

# Create a new workspace
jwa() {
    local name="$1"
    local rev="${2:-@}"

    if [[ -z "$name" ]]; then
        echo "Usage: jwa <name> [revision]"
        return 1
    fi

    local ws_path=$(_jj_ws_path "$name")

    if [[ -d "$ws_path" ]]; then
        echo "Workspace exists: $ws_path"
        echo "Use: jwgo $name"
        return 1
    fi

    jj workspace add "$ws_path" -r "$rev" --name "$name"
    echo "Created. Enter with: jwgo $name"
}

# Open workspace in Zed (stay in current terminal)
jwzed() {
    local ws_path=$(_jj_ws_path "$1")

    if [[ ! -d "$ws_path" ]]; then
        echo "Not found: $ws_path"
        return 1
    fi

    zed "$ws_path"
}

# Rebase + update all workspaces (replaces jrbom for multi-workspace)
jrbomw() {
    echo "=== Checking workspaces ==="
    local dirty=""

    for ws in $(jj workspace list | awk '{print $1}'); do
        if [[ $(jj log -r "$ws@" --no-graph -T 'if(!empty, "1")' 2>/dev/null) == "1" ]]; then
            echo "⚠️  $ws has uncommitted changes"
            dirty="$dirty $ws"
        fi
    done

    if [[ -n "$dirty" ]]; then
        echo ""
        echo "Dirty:$dirty"
        echo "Continue? Changes become recovery commits. (y/N)"
        read -r confirm
        [[ "$confirm" != "y" ]] && return 1
    fi

    echo ""
    echo "=== Rebasing ==="
    jj git fetch && jj rebase --skip-emptied -d main@origin

    echo ""
    echo "=== Updating stale ==="
    jj workspace update-stale

    if jj log -r 'divergent()' --no-graph 2>/dev/null | grep -q .; then
        echo ""
        echo "⚠️  Recovery commits created:"
        jj log -r 'divergent()'
        echo ""
        echo "Squash back with: jj squash --from <id>"
    fi

    echo ""
    jj workspace list
}

# Show all workspaces with their current change
jwall() {
    echo "=== Workspaces ==="
    for ws in $(jj workspace list | awk '{print $1}'); do
        local info=$(jj log -r "$ws@" --no-graph -T 'change_id.short() ++ " " ++ if(empty, "(empty)", "") ++ " " ++ description.first_line()' 2>/dev/null)
        printf "%-12s %s\n" "$ws" "$info"
    done
}

_jj_ws_path() {
    echo "$JJ_WORKSPACES_DIR/$(basename "$(jj root)")-$1"
}

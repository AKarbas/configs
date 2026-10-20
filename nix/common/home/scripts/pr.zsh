# PR helpers — Sourced in ../configs.nix

source ${0:A:h}/jj-main-root.zsh

jsp() {
    local usage='usage: jsp {<rev>... | -r <revset>} [-m <message>]'
    local -a opt_r opt_m
    zparseopts -D -E -F -- r+:=opt_r m:=opt_m || { echo "$usage" >&2; return 2; }
    local revset
    if (( $#opt_r )); then
        (( $#opt_r == 2 && $# == 0 )) || { echo "$usage" >&2; return 2; }
        revset=$opt_r[2]
    else
        (( $# )) || { echo "$usage" >&2; return 2; }
        revset=${(j: | :)@}
    fi
    local revs rev
    revs=$(jj log --no-graph --reversed -r "$revset" -T 'change_id ++ "\n"') || return
    for rev in ${(f)revs}; do
        _jj_spr_diff_in_main_root $opt_m -r "$rev" || return
    done
}

jspa() {
    (( $# )) || { echo "usage: jspa <rev> [jj spr diff flags]" >&2; return 2; }
    local head
    head=$(jj log --no-graph -r "exactly($1, 1)" -T 'change_id') || return
    _jj_spr_diff_in_main_root --all -r "$head" "${@:2}"
}

_jj_spr_diff_in_main_root() {
    local main_root
    main_root=$(_jj_main_root) || return
    (cd "$main_root" && jj spr diff --update-message --cherry-pick "$@")
}

_jsp() {
    [[ $words[CURRENT-1] == -m ]] && return 1
    if [[ $PREFIX == -* ]]; then
        [[ $service == jspa ]] && compadd -- -m || compadd -- -r -m
        return
    fi
    [[ $service == jspa ]] && (( CURRENT > 2 )) && return 1
    local -a revs
    revs=("${(@f)$(COMPLETE=zsh _CLAP_COMPLETE_INDEX=3 _CLAP_IFS=$'\n' jj -- jj log -r "$PREFIX" 2>/dev/null)}")
    _describe revision revs
}
compdef _jsp jsp jspa

ghpr() { _ghpr_links ""; }
ghprd() { _ghpr_links "- "; }

_ghpr_links() {
    setopt local_options pipe_fail
    local main_root
    main_root=$(_jj_main_root 2>/dev/null) || main_root=$PWD
    (cd "$main_root" && gh pr list --author=@me --json url,title) |
        jq -r --arg bullet "$1" 'reverse | .[] | $bullet + "[" + .title + "](" + .url + ")"'
}

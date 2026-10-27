_jj_main_root() {
    local ws_root repo
    ws_root=$(jj root) || return
    if [[ -f "$ws_root/.jj/repo" ]]; then
        # .jj/repo holds an absolute path or a path relative to .jj/
        repo=$(cd -q "$ws_root/.jj" && echo ${$(<repo):A}) || return
        echo "${repo:h:h}"
    else
        echo "$ws_root"
    fi
}

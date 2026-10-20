_jj_main_root() {
    local ws_root
    ws_root=$(jj root) || return
    if [[ -f "$ws_root/.jj/repo" ]]; then
        dirname "$(dirname "$(cat "$ws_root/.jj/repo")")"
    else
        echo "$ws_root"
    fi
}

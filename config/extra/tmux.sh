_kscfg_dependency_add "tmux"

_TMUX_DEFAULT_SESSION="General"

## Automatically start a tmux session on terminal instances
_tmux_start() {
    # Limit autostart to graphical environments without nesting
    if [ -z "${DISPLAY}" ] || [ -n "${TMUX}" ] || [ -n "${TERM_PROGRAM}" ]; then
        return
    fi

    # Start the default session if necessary
    if ! tmux has-session -t "${_TMUX_DEFAULT_SESSION}" 2>/dev/null; then
        _debug "tmux: creating default session"
        exec tmux new-session -s "${_TMUX_DEFAULT_SESSION}" -c "${PWD}"
    fi

    # Compare requested and the default session's working directory
    tcwd="$(
        tmux display-message -t "${_TMUX_DEFAULT_SESSION}" \
            -p "#{pane_current_path}"
    )"
    if [ "${PWD}" != "${tcwd}" ]; then
        _debug "tmux: cwd differs (${PWD} != ${tcwd}), creating new window"
        tmux new-window -t "${_TMUX_DEFAULT_SESSION}" -c "${PWD}"
    fi


    _debug "tmux: attaching default session"
    exec tmux attach-session -t "${_TMUX_DEFAULT_SESSION}"
}
_kscfg_autostart_add "_tmux_start"


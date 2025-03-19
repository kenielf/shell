_dependency_add "tmux"

_TMUX_DEFAULT_SESSION="General"

## Automatically start a tmux session on terminal instances
_tmux_start() {
    # Limit autostart to graphical environments without nesting
    if [ -z "${DISPLAY}" ] || [ -n "${TMUX}" ]; then
        return
    fi

    # Check if default session is started
    sessions="$(tmux ls 2>/dev/null | cut -d: -f1)"
    if ! (echo "${sessions}" | grep -q "${_TMUX_DEFAULT_SESSION}"); then
        # Create it
        _debug "tmux: creating default session"
        exec tmux new -s "${_TMUX_DEFAULT_SESSION}"
    else
        # Attach it
        _debug "tmux: attaching default session"
        exec tmux attach -t "${_TMUX_DEFAULT_SESSION}"
    fi
}
_autostart_add "_tmux_start"


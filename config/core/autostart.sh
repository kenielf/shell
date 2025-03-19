_AUTOSTART_COMMANDS=""

## Adds functions (not full commands!) to be automatically executed on startup
_autostart_add() {
    if [ -z "${1}" ]; then
        _error "autostart: command to be autostarted is missing"
    fi
    _AUTOSTART_COMMANDS="$(_append "${_AUTOSTART_COMMANDS}" "${1}")"
}

## Run all commands in autostart
_autostart_run() {
    for func in ${_AUTOSTART_COMMANDS}; do
        _debug "autostart: running '${func}'"
        "${func}"
    done
}

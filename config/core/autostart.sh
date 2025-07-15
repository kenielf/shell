# shellcheck shell=sh
_KSCFG_AUTOSTART_COMMANDS=""

## Adds functions (not full commands!) to be automatically executed on startup
_kscfg_autostart_add() {
    if [ -z "${1}" ]; then
        _error "autostart: command to be autostarted is missing"
    fi
    _KSCFG_AUTOSTART_COMMANDS="$(_append "${_KSCFG_AUTOSTART_COMMANDS}" "${1}")"
}

## Run all commands in autostart
_kscfg_autostart_run() {
    for func in ${_KSCFG_AUTOSTART_COMMANDS}; do
        _debug "autostart: running '${func}'"
        "${func}"
    done
}

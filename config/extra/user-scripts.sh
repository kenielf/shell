## Creates the folder and add it to path if needed
_path_add() {
    if [ -z "${1}" ]; then
        _error "user-scripts: missing path to add"
        return 1
    fi

    if [ ! -d "${1}" ]; then
        mkdir -p "${1}" || return 1
    fi
    _debug "user-scripts: adding '${1}' to \$PATH"
    PATH="${PATH}:${1}"
}

## Extend path to include user scripts and binaries
_path_add "${HOME}/.scripts/src"
_path_add "${HOME}/.local/bin"
_path_add "${HOME}/.cargo/bin"

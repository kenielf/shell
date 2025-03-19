## Creates a directory if needed and accesses it
mkcd() {
    if [ -z "${1}" ]; then
        _error "navigation: missing path to create and access"
    fi
    mkdir -p "${1}" && cd "${1}"
}

_dependency_add "zoxide"

## Load zoxide (with automatic shell resolution)
eval "$(zoxide init "$(
    echo "${SHELL}" | tr '[:upper:]' '[:lower:]' | awk -F '/' '{print $NF}'
)")"
bind "'\C-f':'zi\n'"

## Path Aliases
export APPDATA="${HOME}/.local/share"
export APPBIN="${HOME}/.local/bin"

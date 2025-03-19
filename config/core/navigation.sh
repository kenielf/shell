_dependency_add "zoxide tree"

## Creates a directory if needed and accesses it
mkcd() {
    if [ -z "${1}" ]; then
        _error "navigation: missing path to create and access"
    fi
    mkdir -p "${1}" && cd "${1}"
}

## Visualization
_TREE_IGNORE='.git|.env|.venv|.idea|.vscode|__pycache__'
alias stree="tree -CFI '${_TREE_IGNORE}' --dirsfisrt"
alias astree="tree -aCFI '${_TREE_IGNORE}' --dirsfisrt"

## Load zoxide (with automatic shell resolution)
eval "$(zoxide init "$(
    echo "${SHELL}" | tr '[:upper:]' '[:lower:]' | awk -F '/' '{print $NF}'
)")"
bind "'\C-f':'zi\n'"

## Path Aliases
export APPDATA="${HOME}/.local/share"
export APPBIN="${HOME}/.local/bin"

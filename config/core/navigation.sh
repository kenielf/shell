_dependency_add "zoxide tree eza vivid"

## Creates a directory if needed and accesses it
mkcd() {
    if [ -z "${1}" ]; then
        _error "navigation: missing path to create and access"
        return 1
    fi
    mkdir -p "${1}" && cd "${1}"
}

## Listing
_DEFAULT_THEME="catppuccin-mocha"
if command -v eza >/dev/null 2>&1; then
    # Generate the theme when needed
    if [ -z "${LS_COLORS}" ] && (command -v vivid >/dev/null 2>&1); then
        export LS_COLORS="$(vivid generate "${_DEFAULT_THEME}")"
    fi

    alias l="eza"
    alias ls="eza -lh"
    alias la="eza -lhA"
fi

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

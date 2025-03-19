# vi: ft=sh
shell="$(echo "${SHELL}" | tr '[:upper:]' '[:lower:]' | awk -F '/' '{print $NF}')"
shellrc="${HOME}/.${shell}rc"
echo ${shellrc}

# Load some basic utilities from the shell configuration itself
. ./config/base/log.sh


# TODO: Make this support zsh as well
if [ "${shell}" != "bash" ]; then
    _error "bootstrap: this shell is not supported."
    exit 1
fi

# Backup shell rc
if [ -f "${shellrc}" ] && [ ! -f "${shellrc}.BAK" ]; then
    _info "Backing up your ${shell} configuration"
    cp "${shellrc}" "${shellrc}.BAK"
fi

# Link the configuration if it wasn't cloned to the ~/.config directory already
CONFIG_DIR="${HOME}/.config/shell"
if [ ! "$(pwd)" = "$(realpath "${CONFIG_DIR}/.." 2>/dev/null)" ]; then
    _info "Linking the configuration"
    ln -sf "$(pwd)/config" "${CONFIG_DIR}"

    [ -f "${shellrc}" ] && rm "${shellrc}"
    ln -sf "$(pwd)/config/rc/bash.sh" ${shellrc}
fi


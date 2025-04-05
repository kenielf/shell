## Prints a message
_msg() {
    if [ -z "${1}" ]; then
        _error "log: missing section"
        return 1
    elif [ -z "${2}" ]; then
        _error "log: missing message"
        return 1
    fi

    printf -- "%b %s\n" "${1}" "${2}"
}

## Types of messages
alias _error="_msg '\x1b[31m[ERROR]\x1b[00m'"
alias _success="_msg '\x1b[32m[SUCCESS]\x1b[00m'"
alias _warn="_msg '\x1b[33m[WARN]\x1b[00m'"
alias _info="_msg '\x1b[34m[INFO]\x1b[00m'"
alias _debug="[ \"\${_SHELL_DEBUG}\" = \"1\" ] && _msg '\x1b[36m[DEBUG]\x1b[00m'"

_SHELL_MODULES_DIR="${HOME}/.config/shell"
_SHELL_MODULES_LOADED=""

## Loads a specific module (recursively if module is a directory)
_module_load() {
    module="${1}"
    if [ -n "${module}" ]; then
        if [ -f "${module}" ]; then
            # Source the module
            . ${module}

            # Add it to the loaded modules
            module_name="$(echo "${1}" | sed -re "s;^${_SHELL_MODULES_DIR}/;;")"
            if [ "${_SHELL_DEBUG}" = "1" ]; then
                _info "shell: loaded ${module_name}"
            fi
            _module_add_to_history "${module_name}"

        elif [ -d "${module}" ]; then
            # Recursively load modules inside the directory
            for item in "${module}"/*; do
                _module_load ${item}
            done
        fi
    fi
}

## Appends a specific module to history
_module_add_to_history() {
    if [ -n "${1}" ]; then
        if [ -z "${_SHELL_MODULES_LOADED}" ]; then
            _SHELL_MODULES_LOADED="${1}"
        else
            _SHELL_MODULES_LOADED="${_SHELL_MODULES_LOADED} ${1}"
        fi
    fi
}

# Load all modules
_module_load "${_SHELL_MODULES_DIR}/base"
_module_load "${_SHELL_MODULES_DIR}/core"
_module_load "${_SHELL_MODULES_DIR}/extra"

# Check dependencies
[ "${_SHELL_DEBUG}" = "1" ] && _dependency_print
_dependency_check

# Autostart
_autostart_run

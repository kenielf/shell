_SHELL_DEPENDENCIES=""

## Adds a dependency from a module to the shell dependency list
_dependency_add() {
    if [ -n "${1}" ]; then
        for dep in "${1}"; do
            _SHELL_DEPENDENCIES="$(_append "${_SHELL_DEPENDENCIES}" "${1}")"
        done
    fi
}

## Checks for any missing dependencies
_dependency_check() {
    missing=""
    missing_count=0
    for dep in $(
        echo "${_SHELL_DEPENDENCIES}" | tr ' ' '\n' | sort | uniq | tr '\n' ' '
    ); do
        # Check if the command exists on the system
        if ! (command -v "${dep}" >/dev/null 2>&1); then
            missing="$(_append "${missing}" "${dep}")"
            missing_count=$((missing_count + 1))
        fi
    done

    if [ -n "${missing}" ]; then
        _error "dependencies: missing ${missing_count} dependencies"
        _error "dependencies: $(_join "${missing}")"
    fi
}

## Prints all dependencies (used for debugging)
_dependency_print() {
    _max_size="$((COLUMNS - 22))" # $COLUMNS - '[INFO] dependencies: '
    sorted="$(echo "${_SHELL_DEPENDENCIES}" | tr ' ' '\n' | sort | uniq)"

    unset deps
    for dep in ${sorted}; do
        next="$(_append "${deps}" "${dep}" ", ")"
        next_size="$(echo "${next}" | wc -c)"
        if [ "${next_size}" -ge "${_max_size}" ]; then
            _info "dependencies: ${deps}"
            next=""
        fi
        deps="${next}"
    done

    if [ -n "${next}" ]; then
        _info "dependencies: ${deps}"
    fi
}

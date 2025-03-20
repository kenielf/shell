_dependency_add "nvim sudo"

## Automatically escalate privileges when editing files
export EDITOR=nvim
edit() {
    # Edit the entire directory if none is specified
    if [ -z "${1}" ]; then
        path="$(pwd)"
    else
        path="${1}"
    fi

    # Check if the file exists and is writeable
    writable=true
    if [ -f "${path}" ] || [ -d "${path}" ]; then
        if [ ! -w "${path}" ]; then
            writable=false
        fi
    else
        # If it does not exist, check if parent directory is writable
        if [ ! -w "$(dirname "${path}")" ]; then
            writable=false
        fi
    fi

    # Privilege escalation
    if [ "${writable}" = true ]; then
        "${EDITOR}" "${path}"
    else
        sudo -E "${EDITOR}" "${path}"
    fi
}
alias e="edit"

_confirm() {
    _prompt_newline "Confirm? (y/N)"
    read -r answer
    if (echo "${answer}" | grep -P '^[\s]*[yY]' >/dev/null 2>&1); then
        return 0;
    fi
    return 1;
}

_prompt_simple() {
    if [ -z "${1}" ]; then
        _error "input: missing content to prompt"
    fi
    printf -- "%s: " "${1}"
}

_prompt_newline() {
    if [ -z "${1}" ]; then
        _error "input: missing content to prompt"
    fi
    printf -- "%s\n > " "${1}"
}

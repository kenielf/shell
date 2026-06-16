# shellcheck shell=sh
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
        return 1
    fi
    printf -- "%s: " "${1}"
}

_prompt_newline() {
    if [ -z "${1}" ]; then
        _error "input: missing content to prompt"
        return 1
    fi
    printf -- "%s\n > " "${1}"
}

_kscfg_cursor_off() { tput civis; }
_kscfg_cursor_on() { tput cvvis cnorm; }

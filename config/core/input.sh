# shellcheck shell=sh
_confirm() {
    _prompt_newline "Confirm? (y/N) "

    if IFS= read -r answer </dev/tty; then
        case ${answer} in
            [yY]*) return 0 ;;
        esac
    fi

    return 1
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

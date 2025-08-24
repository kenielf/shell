# shellcheck shell=sh
_kscfg_progress() {
    if [ -z "${1}" ] || [ -z "${2}" ] || [ -z "${3}" ]; then
        _error "progress: missing argument(s)!"
        return "${_KSCFG_INVALID_USAGE}"
    fi
    step_current="${1}"
    step_total="${2}"
    step_perc="$((step_current * 100 / step_total))"
    counter_string="$(printf -- "] %0${#step_total}d/%d (%03d%%" \
        "${step_current}" "${step_total}" "${step_perc}")"
    real_width="$((${3} - ${#counter_string} - 1))"
    fill_chars="$((step_perc * real_width / 100))"

    printf -- "["
    for _ in $(seq 1 "${fill_chars}"); do printf "|"; done
    for _ in $(seq 1 "$((real_width - fill_chars))"); do printf " "; done
    printf -- "%s\r" "${counter_string}"
}

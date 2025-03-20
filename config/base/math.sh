## Gets the minimum of two values
min() {
    if [ "${#}" -lt 1 ]; then
        _error "math: missing arguments to calculate minimum"
        return 1
    fi

    min="${1}"
    for arg in "${@}"; do
        [ "${arg}" -lt "${min}" ] && min="${arg}"
    done

    printf -- "${min}"
}

## Gets the maximum of two values
max() {
    if [ "${#}" -lt 1 ]; then
        _error "math: missing arguments to calculate maximum"
        return 1
    fi

    max="${1}"
    for arg in "${@}"; do
        [ "${arg}" -lt "${max}" ] && max="${arg}"
    done

    printf -- "${max}"
}

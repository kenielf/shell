_dependency_add "xdg-open"

## Shorthand to open files quietly
open() {
    xdg-open ${@} >/dev/null 2>&1 &
}

## Print the first N lines (1 by default)
first() {
    if [ -z "${1}" ]; then
        _error "files: missing path to read"
    fi

    lines=1
    if [ -n "${2}" ]; then
        if ! _is_number "${2}"; then
            _error "files: lines must be a number"
        fi

        lines="${2}"
    fi

    head -n "${lines}" "${1}"
}


## Print the last N lines (1 by default)
last() {
    if [ -z "${1}" ]; then
        _error "files: missing path to read"
    fi

    lines=1
    if [ -n "${2}" ]; then
        if ! _is_number "${2}"; then
            _error "files: lines must be a number"
        fi

        lines="${2}"
    fi

    tail -n "${lines}" "${1}"
}

## Strip the newline of a given text
stripn() {
    if [ -n "${1}" ]; then
        echo "${1}" | tr -d '\n'
    else
        read -r _content
        echo "${_content}" | tr -d '\n'
    fi
}


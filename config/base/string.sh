## A dedicated function to append text with a space separator
_append() {
    if [ -z "${1}" ]; then
        printf -- "${2}"
    else
        printf -- "${1} ${2}"
    fi
}

## Joins a space separated string with commas (for printing)
_join() {
    if [ -z "${1}" ]; then
        _error "string: missing string to be joined"
    fi
    echo "${1}" | sed 's/ /, /g'
}

## Sorts and joins a space separated string with comas (for printing)
_join_sorted() {
    if [ -z "${1}" ]; then
        _error "string: missing string to be joined"
    fi
    echo "${1}" | sort | sed 's/ /, /g'
}

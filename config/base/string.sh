## A dedicated function to append text with a space separator
_append() {
    # Separator
    if [ "${3}" ]; then
        separator="${3}"
    else
        separator=" "
    fi

    if [ -z "${1}" ]; then
        printf -- "${2}"
    else
        printf -- "${1}${separator}${2}"
    fi
}

## Joins a space separated string with commas (for printing)
_join() {
    if [ -z "${1}" ]; then
        _error "string: missing string to be joined"
        return 1
    fi
    echo "${1}" | sed 's/ /, /g'
}

## Sorts and joins a space separated string with comas (for printing)
_join_sorted() {
    if [ -z "${1}" ]; then
        _error "string: missing string to be joined"
        return 1
    fi
    echo "${1}" | sort | sed 's/ /, /g'
}

## Checks if a string is a number
_is_number() {
    if [ -z "${1}" ]; then
        _error "string: missing string to verify as number"
        return 1
    fi

    if ! (echo "${1}" | grep -P '^[0-9]+$' >/dev/null 2>&1); then
        return 0
    fi
}

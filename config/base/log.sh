## Prints an error message
_error() {
    if [ -z "${1}" ]; then
        error "log: missing error message"
    fi
    printf -- "\x1b[31m[ERROR]\x1b[00m %s\n" "${1}"
}

## Prints a success message
_success() {
    if [ -z "${1}" ]; then
        _error "log: missing success message"
    fi
    printf -- "\x1b[32m[SUCCESS]\x1b[00m %s\n" "${1}"
}

## Prints a warning message
_warn() {
    if [ -z "${1}" ]; then
        _error "log: missing warning message"
    fi

    printf -- "\x1b[34m[WARN]\x1b[00m %s\n" "${1}"
}

## Prints an info message
_info() {
    if [ -z "${1}" ]; then
        _error "log: missing info message"
    fi
    printf -- "\x1b[34m[INFO]\x1b[00m %s\n" "${1}"
}

## Prints a debug message
_debug() {
    if [ -z "${1}" ]; then
        _error "log: missing debug message"
    fi

    if [ "${_SHELL_DEBUG}" = "1" ]; then
        printf -- "\x1b[36m[DEBUG]\x1b[00m %s\n" "${1}"
    fi
}

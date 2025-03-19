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

## Prints an info message
_info() {
    if [ -z "${1}" ]; then
        _error "log: missing info message"
    fi
    printf -- "\x1b[34m[INFO]\x1b[00m %s\n" "${1}"
}

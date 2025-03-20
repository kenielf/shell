## Prints a message
_msg() {
    if [ -z "${1}" ]; then
        _error "log: missing section"
        return 1
    elif [ -z "${2}" ]; then
        _error "log: missing message"
        return 1
    fi

    printf -- "%b %s\n" "${1}" "${2}"
}

## Types of messages
alias _error="_msg '\x1b[31m[ERROR]\x1b[00m'"
alias _success="_msg '\x1b[32m[SUCCESS]\x1b[00m'"
alias _warn="_msg '\x1b[33m[WARN]\x1b[00m'"
alias _info="_msg '\x1b[34m[INFO]\x1b[00m'"
alias _debug="_msg '\x1b[36m[DEBUG]\x1b[00m'"


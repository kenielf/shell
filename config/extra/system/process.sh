_kscfg_dependency_add "killall ps tail sed cut fzf"

alias ka="killall"

pk() {
    # TODO: Implement multi-choice killing
    all=false
    if [ "${1}" = "-a" ]; then
        all=true
    fi
    procs="$(ps -eux | tail -n+2 | sed -re 's/[ \t]+/ /g' | cut -d' ' -s -f2,11)"
    choice="$(echo "${procs}" | fzf --prompt="|> Kill > ")"
    if [ -z "${choice}" ]; then
        return "${_KSCFG_INVALID_USAGE}"
    fi

    if [ "${all}" = true ]; then
        killall "$(echo "${choice}" | cut -d' ' -f2)"
    else
        choice="$(echo "${choice}" | cut -d' ' -f1)"
        if [ -n "${choice}" ]; then
            kill "${choice}"
        fi
    fi
}


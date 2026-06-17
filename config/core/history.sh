# shellcheck shell=sh
## History configuration
export HISTFILE="${HOME}/.local/share/history"
export HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S%z "
export HISTCONTROL=ignores
export HISTSIZE=-1
export HISTFILESIZE=-1

_kscfg_dependency_add "fzf"

# FIXME: cannot run confirmation when executing
## Select and run a command in history
_kscfg_history_rerun() {
    # Fetch all history, sort it and remove duplicates
    cmds="$(history | \
        awk '{$1=$2=""; print $0}' | \
        sed -re 's/^ //g' | \
        sort | uniq
    )"

    # Execute the commands given the user input
    command="$(echo "${cmds}" | fzf --info=inline --prompt="History > ")"
    if [ -n "${command}" ]; then
        echo "Running: ${command}"
        eval "${command}"
    fi
}
alias ih="_kscfg_history_rerun"
if [ "${KSCFG_BINDINGS}" = 1 ]; then
    bind -x "\"${_KSCFG_BIND_PREFIX}h\":\"_kscfg_history_rerun\""
fi

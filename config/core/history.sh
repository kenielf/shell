# shellcheck shell=sh
## History configuration
export HISTFILE="${HOME}/.local/share/history"
export HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S%z "
export HISTCONTROL=ignores
export HISTSIZE=-1
export HISTFILESIZE=-1

_kscfg_dependency_add "fzf"

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
        # Under `bind -x` readline leaves the tty raw (-icanon -echo -icrnl),
        # so prompts never see Enter; confirm and run in cooked mode
        _h_stty="$(stty -g 2>/dev/null)"
        stty icanon echo icrnl 2>/dev/null
        _h_status=0
        if _confirm "Run: ${command}"; then
            eval "${command}"
            _h_status=$?
        fi
        [ -n "${_h_stty}" ] && stty "${_h_stty}" 2>/dev/null
        unset _h_stty
        return "${_h_status}"
    fi
}
alias ih="_kscfg_history_rerun"
if [ "${KSCFG_BINDINGS}" = 1 ]; then
    bind -x "\"${_KSCFG_BIND_PREFIX}h\":\"_kscfg_history_rerun\""
fi

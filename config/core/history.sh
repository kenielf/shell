## History configuration
export HISTFILE="${HOME}/.local/share/history"
export HISTTIMEFORMAT="%Y-%m-%dT%H:%M:%S%z "
export HISTCONTROL=ignores
export HISTSIZE=-1
export HISTFILESIZE=-1

_dependency_add "fzf"

## Select and run a command in history
_history_interactive_run() {
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
        _confirm && eval "${command}"
    fi
}
alias ih="_history_interactive_run"
bind "'\C-h':'ih\n'"

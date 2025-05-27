## Interactive Safeguard
[[ $- != *i* ]] && return

## Options
shopt -s histappend  # Append to the history file without rewriting
shopt -s checkwinsize  # Update LINES and COLUMNS after commands

# Load modules
# _SHELL_DEBUG=1  # Uncomment this to enable debug messages
. ${HOME}/.config/shell/init.sh

# Disable freezing
stty -ixon

# Reload configuration via keybind
reload() {
    clear
    if [ "${1}" = "-d" ]; then
        _SHELL_DEBUG=1 . ~/.bashrc
    else
        _SHELL_DEBUG=0 . ~/.bashrc
    fi
}

bind "'\C-s':'reload\n'"

## Prompt handler
function prepare_prompt() {
    columns="$(tput cols)"
    right_text="$(eval "echo \"${RPS1}\"")"
    right_text_length=${#right_text}
    printf '%*s%s\r' "$((columns - right_text_length))" '' "${right_text}"
}

export PROMPT_COMMAND=prepare_prompt


## TODO: Prompt
PS_PATH="\[\e[90m\]\W\[\e[00m\]"
PS_PROMPT="\[\e[35m\]λ\[\e[00m\] "
PS_GIT="\$(_git_parse_branch)"
PS_JOBS="\[\e[90m\]\$(_jobs_parse_numbers)\[\e[00m\]"

PS1=" ${PS_PATH}${PS_GIT}${PS_JOBS} ${PS_PROMPT}"
export PS1

export RPS1="\$(_git_parse_name)"

## Clearing
bind -x '"\C-l": clear -x; ${PROMPT_COMMAND}'

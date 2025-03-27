## Interactive Safeguard
[[ $- != *i* ]] && return

## Options
shopt -s histappend  # Append to the history file without rewriting
shopt -s checkwinsize  # Update LINES and COLUMNS after commands

# Load modules
# _SHELL_DEBUG=1  # Uncomment this to enable debug messages
. ${HOME}/.config/shell/init.sh

## TODO: Prompt
PS_PATH="\[\e[90m\]\W\[\e[00m\]"
PS_PROMPT="\[\e[35m\]λ\[\e[00m\] "
PS_GIT="\$(_git_parse_branch)"
PS_JOBS="\[\e[90m\]\$(_jobs_parse_numbers)\[\e[00m\]"

PS1=" ${PS_PATH}${PS_GIT}${PS_JOBS} ${PS_PROMPT}"

export PS1

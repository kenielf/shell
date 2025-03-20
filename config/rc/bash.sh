## Options
shopt -s histappend  # Append to the history file without rewriting
shopt -s checkwinsize  # Update LINES and COLUMNS after commands

# Load modules
# _SHELL_DEBUG=1  # Uncomment this to enable debug messages
. ${HOME}/.config/shell/init.sh

## TODO: Prompt
PS_PATH="\[\e[90m\]\W\[\e[00m\]"
PS_PROMPT="\[\e[35m\]λ\[\e[00m\] "
export PS1=" ${PS_PATH}\$(_parse_git_branch) ${PS_PROMPT}"


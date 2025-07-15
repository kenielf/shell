# shellcheck shell=sh
_kscfg_dependency_add "ssh"

_ssh_eval_agent() {
    if [ ! -S "${HOME}/.ssh/ssh_auth_sock" ]; then
        eval $(ssh-agent) >/dev/null
        ln -sf "${SSH_AUTH_SOCK}" ~/.ssh/ssh_auth_sock
    fi
    export SSH_AUTH_SOCK="${HOME}/.ssh/ssh_auth_sock"
}
_kscfg_autostart_add "_ssh_eval_agent"


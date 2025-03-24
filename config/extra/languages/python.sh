_dependency_add "python3"

## Python virtual environments
pyenv() {
    # Derive the env directory
    _env_dir="./.env"
    if [ -f "${_env_dir}" ]; then
        # alternative directory, since .env can be an existing file
        _env_dir="./.venv"
    fi

    # Source it if it already exists
    if [ -d "${_env_dir}" ]; then
        source "${_env_dir}/bin/activate"
        _info "python: sourced environment (${_env_dir})"
        return
    fi

    # Otherwise, create it and source it
    _debug "python: creating environment"
    python3 -m venv "${_env_dir}"
    . "${_env_dir}/bin/activate"

    if [ -f "./requirements.txt" ]; then
        _info "python: installing environment dependencies"
        _cmd="uv"
        if ! (command -v "${_cmd}" >/dev/null 2>&1); then
            _cmd "python3 -m"
        fi
        ${_cmd} pip install -r "./requirements.txt"
    fi
    _info "python: finished setting up environment"
}


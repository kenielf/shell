_dependency_add "python3"

## Python virtual environments
_python_env_create="python3 -m venv ./.env"
_python_env_load="source ./.env/bin/activate"
alias pec="_python_env_create"
alias pel="_python_env_load"


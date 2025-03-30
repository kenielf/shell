_dependency_add "fzf"

## This must be a pipe separated list :D
JOB_BLACKLIST="zoxide|nvim"

## Get the amount of jobs as a number (to be used in prompts)
_jobs_parse_numbers() {
    _jobs="$(jobs | grep -vP "${JOB_BLACKLIST}" | wc -l)"
    if [ "${_jobs}" -ge 1 ]; then
        echo " (${_jobs})"
    else
        echo ""
    fi
}

## Move process to foreground interactively using fzf
# fgi() {}

## Move process to background interactively using fzf
# bgi() {}

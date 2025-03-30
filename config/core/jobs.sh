_dependency_add "fzf"

## This must be a pipe separated list :D
JOB_BLACKLIST="zoxide"

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
fgi() {
    # Find all jobs that aren't done
    _jobs="$(jobs | grep -v 'Done' | wc -l)"

    if [ "${_jobs}" -ge 1 ]; then
        # Get job number and foreground it
        _chosen="$(jobs | fzf | grep -Po '\[[0-9]+\]' | tr -d '[]')"
        fg %${_chosen}
    fi
}

## Move process to background interactively using fzf
bgi() {
    # Find all jobs that aren't done
    _jobs="$(jobs | grep -v 'Done' | wc -l)"

    if [ "${_jobs}" -ge 1 ]; then
        # Get job number and foreground it
        _chosen="$(jobs | fzf | grep -Po '\[[0-9]+\]' | tr -d '[]')"
        bg %${_chosen}
    fi
}

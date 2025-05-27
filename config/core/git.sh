_dependency_add "git fzf"

GIT_FETCH_TIMESTAMP_FILE="./.git/git-fetch.timestamp"
GIT_FETCH_TIMEOUT=300  # 5 Minute
GIT_EXTENSION_FILE="${HOME}/.config/git-extras.config"

## Show the current git branch or nothing
_git_parse_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/  (\1)/'
}

_git_parse_name() {
    if [ -d "./.git" ]; then
        name="$(git config --list | tac | grep -m1 -Po '^user\.name=\K.*')"
        email="$(git config --list | tac | grep -m1 -Po '^user\.email=\K.*')"
        if [ -n "${name}" ] && [ -n "${email}" ]; then
            printf -- "%s (%s)\n" "${name}" "${email}"
        fi
    fi
}

_git_register_name_for_key() {
    if [ -z "${1}" ] || [ -z "${2}" ]; then
        _error "git: missing arguments to register a name to a key"
        return 1
    fi

    if (grep -P "^${1}" "${GIT_EXTENSION_FILE}" >/dev/null 2>&1); then
        sed -i "s/^${1},.*/${1},${2}" "${GIT_EXTENSION_FILE}"
    else
        printf -- "%s,%s"  "${1}" "${2}" >> "${GIT_EXTENSION_FILE}"
    fi
}

_git_check_name_for_key() {
    if [ -z "${1}" ]; then
        _error "git: missing key to check"
        return 1
    fi

    # Make sure that the extension file exists
    if [ ! -f "${GIT_EXTENSION_FILE}" ]; then
        printf -- "# vi: ft=csv\n" > "${GIT_EXTENSION_FILE}"
    fi

    result="$(grep -m1 -P "^${1}" "${GIT_EXTENSION_FILE}" 2>/dev/null)"
    if [ -z "${result}" ]; then
        _debug "git: key not registered"
    else
        echo "${result}" | awk -F ',' '{ print $2 }'
    fi
}

## Change git signing key interactively
git-change-key() {
    # Make sure user is inside of a git repository
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        _error "git: not a repository"
        return 1
    fi

    # Find all keys
    keys="$(gpg --list-secret-keys --with-colons | \
        awk -F ':' '/^fpr/ {fpr = $10} /uid/ {print fpr "|" $8 "|" $10}'
    )"

    # Print options
    echo "Choose a key:"
    index=1
    echo "${keys}" | while IFS="|" read -r fingerprint key label; do
        # Extract the key information
        author="$(echo "${label}" | sed -e 's/ (.*//')"
        description="$(echo "${label}" | sed -e 's/^[^(]*(\([^)]*\)).*/\1/')"
        email="$(echo "${label}" | sed -e 's/.*<\(.*\)>/\1/')"

        # Print options and increment
        printf -- "  \e[34m%2d)\e[00m %s\n      %s <%s>\n      %s\n" \
            "${index}" "${description}" "${author}" "${email}" "${fingerprint}"
        index=$((index + 1))
    done
    count="$((index + 1))"

    # Parse the user input
    while true; do
        printf -- "\r\e[K \e[34m>\e[00m "
        read -r choice

        if [ "${choice}" -ge 1 ] && [ "${choice}" -le "${count}" ]; then
            # Getting fingerprint and email
            fingerprint="$(echo "${keys}" | sed -n "${choice}p" | cut -d '|' -f1)"
            key="$(echo "${keys}" | sed -n "${choice}p" | cut -d '|' -f2)"
            email="$(echo "${keys}" | sed -n "${choice}p" | cut -d '|' -f3 | \
                grep -oP '<.*>' | tr -d '<>')"
            name="$(_git_check_name_for_key "${key}")"
            if [ -z "${name}" ]; then
                _prompt_newline "Please set your user.name for the key '${key}'"
                read -r name
                _git_register_name_for_key "${key}" "${name}"
            fi

            # Set the configurations
            echo "Setting key..."
            git config --local user.signingkey "${fingerprint}"
            git config --local user.email "${email}"
            git config --local user.name "${name}"

            # Finish
            break
        else
            printf -- "\r%s" "Invalid selection"
            sleep 0.5
        fi
    done
}

_git_log_remote() {
    if [ ! -d "./.git" ]; then
        _error "git: not a repository"
        return 1
    fi

    if [ -z "${1}" ]; then
        _error "git: missing branch argument"
        return 1
    fi

    git log --color=always "${1}" || \
        git log --color=always "origin/${1}"
}
_export_function _git_log_remote

## Interactively change branch
gci() {
    if [ ! -d "./.git" ]; then
        _error "git: not a repository"
        return 1
    fi

    # Check if updating references is necessary
    _fetch=false
    if [ "${1}" = "-f" ]; then
        _fetch=true  # Force update
    elif [ -f "${GIT_FETCH_TIMESTAMP_FILE}" ]; then
        # Grab unix timestamps (whole integers)
        now="$(date -u +"%s")"
        last_modified="$(date -d "$(
            stat "${GIT_FETCH_TIMESTAMP_FILE}" | grep -Po "Modify: \K.*"
        )" +"%s")"

        if [ "${now}" -gt "$((last_modified + GIT_FETCH_TIMEOUT))" ]; then
            _fetch=true
        fi
    else
        _fetch=true  # Fetch timestamp file does not exist - needs checking
    fi

    # Update branch references
    if [ "${_fetch}" = true ]; then
        _info "git: fetching branches"
        git fetch -a >/dev/null
        touch "${GIT_FETCH_TIMESTAMP_FILE}"
    fi
    branches="$(git branch -a)"

    # Select a branch
    selection="$(
        echo "${branches}" | sed -re 's;remotes/origin/;;g;s;^  |\* ;;g' | \
            sort | uniq | grep -v 'HEAD' | \
        fzf --cycle --reverse --ansi \
            --preview '_git_log_remote {}' --prompt="Branch > "
    )"

    if [ -n "${selection}" ]; then
        _info "git: switching to branch '${selection}'"
        git checkout "${selection}"
    fi
}

_dependency_add "git"

## Show the current git branch or nothing
_parse_git_branch() {
     git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/  (\1)/'
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
            fingerprint="$(
                echo "${keys}" | sed -n "${choice}p" | cut -d '|' -f1
            )"
            email="$(
                echo "${keys}" | sed -n "${choice}p" | cut -d '|' -f3 | \
                    grep -oP '<.*>' | tr -d '<>'
            )"

            # Set the configurations
            echo "Setting key..."
            git config --local user.signingkey "${fingerprint}"
            git config --local user.email "${email}"

            # Finish
            break
        else
            printf -- "\r%s" "Invalid selection"
            sleep 0.5
        fi
    done
}

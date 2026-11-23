# shellcheck shell=sh
_kscfg_dependency_add "git fzf"

GIT_FETCH_TIMESTAMP_FILE="git-fetch.timestamp"  # Inside the common git dir
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

## Worktree helpers
# Worktrees are the default unit of work: switching branches moves you to that
# branch's worktree (creating it if needed) instead of checking out in place.
#
# Layouts:
#   bare (created by `g c`):     regular repository:
#     project/                     project/            <- main worktree
#       .bare/   <- git dir          .git/
#       .git     <- "gitdir: ./.bare" project.worktrees/
#       main/                          feature-x/
#       feature-x/

## Absolute path to the git dir shared by every worktree
_kscfg_git_common_dir() {
    git rev-parse --path-format=absolute --git-common-dir 2>/dev/null
}

## Directory where new worktrees are created
_kscfg_git_worktree_root() {
    _g_common="$(_kscfg_git_common_dir)" || return 1
    if [ "$(git --git-dir="${_g_common}" config --bool core.bare)" = "true" ]; then
        dirname "${_g_common}"
    else
        printf -- "%s.worktrees\n" "$(dirname "${_g_common}")"
    fi
}

## Path of the worktree that has <branch> checked out, or nothing
_kscfg_git_worktree_for() {
    git worktree list --porcelain | awk -v ref="refs/heads/${1}" '
        /^worktree / { path = substr($0, 10) }
        $0 == "branch " ref { print path; exit }
    '
}

## Branch log preview for fzf (_git_log_remote requires a ./.git directory,
## which is a file inside worktrees)
_kscfg_git_preview() {
    git log --color=always "${1}" -- 2>/dev/null || \
        git log --color=always "origin/${1}" --
}
_export_function _kscfg_git_preview

## Clone as a bare repository with one worktree per branch
## _kscfg_gclone [-c] <url> [directory]
##   -c: classic `git clone` (remaining arguments are passed through)
_kscfg_gclone() {
    if [ "${1}" = "-c" ]; then
        shift
        git clone "${@}"
        return
    fi

    if [ -z "${1}" ]; then
        _error "git: missing repository url"
        return 1
    fi

    _g_url="${1}"
    _g_dir="${2:-$(basename "${_g_url%/}" .git)}"
    if [ -e "${_g_dir}" ]; then
        _error "git: '${_g_dir}' already exists"
        return 1
    fi

    _info "git: cloning '${_g_url}' into '${_g_dir}'"
    git clone --bare "${_g_url}" "${_g_dir}/.bare" || return 1
    printf -- "gitdir: ./.bare\n" > "${_g_dir}/.git"

    # Bare clones do not track remote branches, enable it
    git -C "${_g_dir}" config remote.origin.fetch \
        "+refs/heads/*:refs/remotes/origin/*"
    git -C "${_g_dir}" fetch origin >/dev/null 2>&1

    # Keep only the default branch locally, others are created on demand
    _g_default="$(git -C "${_g_dir}" symbolic-ref --short HEAD)"
    git -C "${_g_dir}" for-each-ref --format='%(refname:short)' refs/heads | \
        grep -vx "${_g_default}" | while read -r _g_branch; do
            git -C "${_g_dir}" branch -q -D "${_g_branch}"
        done
    git -C "${_g_dir}" branch -q --set-upstream-to="origin/${_g_default}" \
        "${_g_default}" 2>/dev/null

    _g_path="${_g_dir}/$(printf -- "%s" "${_g_default}" | tr '/' '-')"
    if git -C "${_g_dir}" worktree add "${_g_path##"${_g_dir}/"}" \
        "${_g_default}" >/dev/null 2>&1; then
        cd "${_g_path}" || return 1
    else
        _warn "git: could not create a worktree for '${_g_default}'"
        cd "${_g_dir}" || return 1
    fi
}

## Move to the worktree of <branch>, creating it if needed
## _kscfg_git_goto <branch> [base]
##   base: create <branch> as a new branch starting at <base>
_kscfg_git_goto() {
    _g_prefix="$(git rev-parse --show-prefix 2>/dev/null)"
    _g_path="$(_kscfg_git_worktree_for "${1}")"
    if [ -z "${_g_path}" ]; then
        _g_path="$(_kscfg_git_worktree_root)/$(
            printf -- "%s" "${1}" | tr '/' '-'
        )"
        if [ -e "${_g_path}" ]; then
            _error "git: '${_g_path}' already exists"
            return 1
        fi

        _info "git: creating worktree for '${1}'"
        if [ -n "${2}" ]; then
            git worktree add --no-track -b "${1}" "${_g_path}" "${2}" \
                >/dev/null || return 1
        else
            git worktree add "${_g_path}" "${1}" >/dev/null || return 1
        fi
    fi

    # Move into it, keeping the current subdirectory when possible
    _info "git: switching to worktree '${_g_path}'"
    cd "${_g_path}" || return 1
    if [ -n "${_g_prefix}" ] && [ -d "${_g_prefix}" ]; then
        cd "${_g_prefix}" || return 1
    fi
}

## Create a new branch in its own worktree and move into it
## _kscfg_gwn [-c] <branch> [base]
##   base: starting point, defaults to HEAD (the current branch)
##   -c: classic `git switch -c` in the current worktree
_kscfg_gwn() {
    _g_classic=false
    if [ "${1}" = "-c" ]; then
        _g_classic=true
        shift
    fi

    if [ -z "${1}" ]; then
        _error "git: missing branch name"
        return 1
    elif ! git rev-parse --git-dir >/dev/null 2>&1; then
        _error "git: not a repository"
        return 1
    elif ! git check-ref-format --branch "${1}" >/dev/null 2>&1; then
        _error "git: '${1}' is not a valid branch name"
        return 1
    elif git show-ref --quiet --verify "refs/heads/${1}" || \
        git show-ref --quiet --verify "refs/remotes/origin/${1}"; then
        _error "git: branch '${1}' already exists, use 'g ci' to switch to it"
        return 1
    fi

    _g_base="${2:-HEAD}"
    if ! git rev-parse --quiet --verify "${_g_base}^{commit}" >/dev/null; then
        _error "git: '${_g_base}' is not a valid starting point"
        return 1
    fi

    if [ "${_g_classic}" = true ]; then
        git switch --no-track -c "${1}" "${_g_base}"
    else
        _kscfg_git_goto "${1}" "${_g_base}"
    fi
}

## Interactively change branch (switches to the branch's worktree)
## _kscfg_gci [-f] [-c]
##   -f: force fetching remote references
##   -c: classic `git checkout` in the current worktree
_kscfg_gci() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        _error "git: not a repository"
        return 1
    fi

    _g_fetch=false
    _g_classic=false
    while [ "${#}" -gt 0 ]; do
        case "${1}" in
            "-f") _g_fetch=true;;
            "-c") _g_classic=true;;
            *) _error "git: unknown option '${1}'"; return 1;;
        esac
        shift
    done

    _g_common="$(_kscfg_git_common_dir)"

    # Bare repositories not created by `g c` may lack remote tracking
    if [ "$(git config --bool core.bare)" = "true" ] && \
        [ -z "$(git config remote.origin.fetch)" ] && \
        git remote get-url origin >/dev/null 2>&1; then
        git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
        _g_fetch=true
    fi

    # Check if updating references is necessary (shared by all worktrees)
    _g_stamp="${_g_common}/${GIT_FETCH_TIMESTAMP_FILE}"
    if [ ! -f "${_g_stamp}" ] || [ "$(date -u +"%s")" -gt \
        "$(($(stat -c "%Y" "${_g_stamp}") + GIT_FETCH_TIMEOUT))" ]; then
        _g_fetch=true
    fi

    # Update branch references
    if [ "${_g_fetch}" = true ]; then
        _info "git: fetching branches"
        git fetch --all --prune >/dev/null
        touch "${_g_stamp}"
    fi

    # Select a branch
    _g_selection="$(
        git for-each-ref --format='%(refname:short)' \
            refs/heads refs/remotes/origin | \
            sed -e 's;^origin/;;' | grep -vx -e 'HEAD' -e 'origin' | sort -u | \
        fzf --cycle --reverse --ansi \
            --preview '_kscfg_git_preview {}' --prompt="Branch > "
    )"
    [ -z "${_g_selection}" ] && return 0

    if [ "${_g_classic}" = true ]; then
        _info "git: switching to branch '${_g_selection}'"
        git checkout "${_g_selection}"
        return
    fi

    _kscfg_git_goto "${_g_selection}"
}

## Interactively remove a worktree
## _kscfg_gwr [git worktree remove options]
_kscfg_gwr() {
    _g_path="$(
        git worktree list | grep -v '(bare)$' | \
            fzf --cycle --reverse --prompt="Remove worktree > " | \
            awk '{ print $1 }'
    )"
    [ -z "${_g_path}" ] && return 0

    # Step out of the worktree before removing it
    case "${PWD}/" in
        "${_g_path}/"*) cd "$(_kscfg_git_worktree_root)" || return 1;;
    esac

    _info "git: removing worktree '${_g_path}'"
    git worktree remove "${@}" "${_g_path}"
}

## Remove worktrees (and their branches) whose upstream is gone from the remote
## _kscfg_gwc [-n] [-f]
##   -n: dry run, only list what would be removed
##   -f: also remove worktrees with local changes
## Branches that never had an upstream (unpushed, e.g. fresh `g wn`) are kept.
_kscfg_gwc() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        _error "git: not a repository"
        return 1
    fi

    _g_dry=false
    _g_force=""
    while [ "${#}" -gt 0 ]; do
        case "${1}" in
            "-n") _g_dry=true;;
            "-f") _g_force="-f";;
            *) _error "git: unknown option '${1}'"; return 1;;
        esac
        shift
    done

    # Prune deleted remote branches so their upstreams show up as gone
    _info "git: fetching branches"
    git fetch --all --prune >/dev/null || return 1
    touch "$(_kscfg_git_common_dir)/${GIT_FETCH_TIMESTAMP_FILE}"
    git worktree prune

    _g_gone="$(
        git for-each-ref --format='%(refname:short)|%(upstream:track)' \
            refs/heads | awk -F '|' '$2 == "[gone]" { printf "%s ", $1 }'
    )"

    # "<branch>\t<path>" for each worktree on a gone branch, skipping the
    # first entry (the main worktree, or the bare repository itself)
    _g_list="$(
        git worktree list --porcelain | awk -v gone="${_g_gone}" '
            BEGIN { n = split(gone, a, " "); for (i = 1; i <= n; i++) g[a[i]] }
            /^worktree / { path = substr($0, 10); idx++ }
            /^branch refs\/heads\// {
                b = substr($0, 19)
                if (idx > 1 && (b in g)) print b "\t" path
            }
        '
    )"
    if [ -z "${_g_list}" ]; then
        _info "git: no worktrees to clean"
        return 0
    fi

    print "Worktrees whose branch is gone from the remote:"
    printf -- "%s\n" "${_g_list}" | while IFS="$(printf '\t')" read -r _g_b _g_p; do
        printf -- "  \e[34m%s\e[00m  %s\n" "${_g_b}" "${_g_p}"
    done
    [ "${_g_dry}" = true ] && return 0
    _confirm || return 0

    _g_status=0
    _g_tab="$(printf '\t')"
    _g_root="$(_kscfg_git_worktree_root)"
    while IFS="${_g_tab}" read -r _g_b _g_p; do
        # Step out of the worktree before removing it
        case "${PWD}/" in
            "${_g_p}/"*) cd "${_g_root}" || return 1;;
        esac

        _info "git: removing worktree '${_g_p}'"
        if git worktree remove ${_g_force} "${_g_p}"; then
            git branch -D "${_g_b}"
        else
            _g_status=1
        fi
    done <<EOF
${_g_list}
EOF
    return "${_g_status}"
}

## Stage changes: untracked files whole, tracked changes interactively
## _kscfg_gadd [pathspec...]  (defaults to the current directory)
_kscfg_gadd() {
    if ! git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        _error "git: not inside a worktree"
        return 1
    fi
    [ "${#}" -eq 0 ] && set -- "."

    # Fail early on paths that match nothing (typos, already ignored files)
    for _g_spec in "${@}"; do
        if [ -z "$(git ls-files --cached --others --deleted \
            --exclude-standard -- "${_g_spec}" | head -n1)" ]; then
            _error "git: '${_g_spec}' did not match any files"
            return 1
        fi
    done

    # Untracked files have no hunks to choose from, add them as a whole
    git ls-files -z --others --exclude-standard -- "${@}" | \
        xargs -0 -r git add --

    # Tracked changes (modifications, deletions, modes) are picked hunk by hunk
    if ! git diff --quiet -- "${@}"; then
        git add --patch -- "${@}"
    fi
}

## Signed commit, drafting the message with gmsg when no message is given
## _kscfg_gcm [<message> | [-h <hint>]... [-t <ticket>]]
##   <message>:   plain `git commit -S -m <message>`
##   -h <hint>:   hint for gmsg (repeatable), the draft opens in the editor
##   -t <ticket>: ticket for gmsg's "Refs:" footer and context; when omitted,
##                gmsg picks it from $FORCE_ID or the branch name (PROJ-123)
_kscfg_gcm() {
    case "${1}" in
        ""|"-h"|"--hint"|"-t"|"--ticket") ;;
        *) git commit -S -m "${@}"; return;;
    esac

    if ! command -v gmsg >/dev/null 2>&1; then
        if [ "${#}" -gt 0 ]; then
            _error "git: hints and tickets require gmsg, which was not found"
            return 1
        fi
        git commit -S
        return
    fi

    if git diff --cached --quiet; then
        _error "git: no staged changes"
        return 1
    fi

    # Equivalent to `git commit -e -F <(gmsg ...)`, which is not POSIX
    _g_msg="$(mktemp)" || return 1
    if gmsg "${@}" > "${_g_msg}" && [ -s "${_g_msg}" ]; then
        git commit -S -e -F "${_g_msg}"
        _g_status="${?}"
    else
        _error "git: gmsg failed to draft a message"
        _g_status=1
    fi
    rm -f "${_g_msg}"
    return "${_g_status}"
}

## Push, setting the upstream only when it is not already origin/<branch>
## _kscfg_gpu [git push options]
_kscfg_gpu() {
    _g_branch="$(git branch --show-current)"
    if [ -z "${_g_branch}" ]; then
        _error "git: not on a branch"
        return 1
    fi

    if [ "$(git rev-parse --abbrev-ref '@{upstream}' 2>/dev/null)" = \
        "origin/${_g_branch}" ]; then
        git push "${@}"
    else
        _info "git: setting upstream to 'origin/${_g_branch}'"
        git push --set-upstream "${@}" origin "${_g_branch}"
    fi
}

## Shows usage for `g`
## _kscfg_ghelp
_kscfg_ghelp() {
    print "g: git shorthands (worktree-first, see docs/git.md)"
    while IFS='|' read -r _g_cmd _g_args _g_desc; do
        if [ -z "${_g_cmd}" ]; then
            print ""  # Section separator
        else
            printf -- "  \e[34m%-3s\e[00m %-22s %s\n" \
                "${_g_cmd}" "${_g_args}" "${_g_desc}"
        fi
    done <<EOF
h||Shows this usage.
||
c|[-c] <url> [dir]|Clones as bare repo + worktrees (-c: plain git clone).
ci|[-f] [-c]|Switches to a branch's worktree (-f: fetch, -c: checkout).
w||Lists worktrees.
wn|[-c] <branch> [base]|Creates a branch in a new worktree (-c: git switch -c).
wr|[-f]|Removes a worktree interactively.
wp||Prunes stale worktrees.
wc|[-n] [-f]|Removes worktrees whose branch is gone from the remote.
||
a|[paths...]|Stages untracked files whole, tracked changes by hunk.
cm|[<msg> | -h <hint>... -t <ticket>]|Signed commit (no msg: drafted by gmsg).
s||Shows the status.
||
st||Moves changes to the stash.
sl||Lists the stash.
sp||Pops the stash.
||
p||Pushes.
pu|[push options]|Pushes, setting upstream to origin/<branch> if needed.
pt||Pushes tags.
EOF
}

g() {
    case "${1}" in
        "h") _kscfg_ghelp;;                         # Usage
        "c") shift; _kscfg_gclone "${@}";;          # Clone
        "cm") shift; _kscfg_gcm "${@}";;            # Commit
        "ci") shift; _kscfg_gci "${@}";;            # Change Branch
        "a") shift; _kscfg_gadd "${@}";;            # Add
        "s") git status;;                           # Status
        "st") git stash;;                           # Move to Stash
        "sl") git stash list;;                      # List Stash
        "sp") git stash pop;;                       # Pop Stash
        "p") git push;;                             # Push
        "pu") shift; _kscfg_gpu "${@}";;            # Push (Update Upstream)
        "pt") git push --tags;;                     # Push Tags
        "w") git worktree list;;                    # List Worktrees
        "wn") shift; _kscfg_gwn "${@}";;            # New Branch/Worktree
        "wr") shift; _kscfg_gwr "${@}";;            # Remove Worktree
        "wp") git worktree prune -v;;               # Prune Worktree
        "wc") shift; _kscfg_gwc "${@}";;            # Clean Worktrees
        "") _kscfg_ghelp;;                          # Usage (no command)
        *) _error "g: unknown command '${1}'"; _kscfg_ghelp; return 1;;
    esac
}

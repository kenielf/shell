# shellcheck shell=sh
_kscfg_dependency_add "ncal"

## ncal shortcut
if ! command -v cal >/dev/null; then
    cal() {
        ncal -b "${@}"
    }
fi

# shellcheck shell=sh

## ncal shortcut
if ! command -v cal >/dev/null; then
    _kscfg_dependency_add "ncal"
    cal() {
        ncal -b "${@}"
    }
fi

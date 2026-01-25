_kscfg_dependency_add "bc"

qc() {
    if [ $# -gt 0 ]; then
        _expr="${1}"
        echo "${_expr}" | bc
        return
    fi

    while true; do
        printf -- " > "
        read -r _expr
        echo "${_expr}" | bc
    done
}

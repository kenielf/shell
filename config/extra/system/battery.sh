_dependency_add "upower"

batinfo() {
    if [ "${1}" = "-l" ]; then
        while true; do
            info="$(upower -i "$(upower -e | grep 'BAT')")"
            len="$(echo "${info}" | wc -l)"

            clear
            echo "${info}" | head -n "$(min "${len}" "$((LINES - 1))")"
            sleep 1
        done
    else
        upower -i "$(upower -e | grep 'BAT')"
    fi
}

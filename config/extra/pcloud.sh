_dependency_add "pcloudcc"

_PCLOUD_DIR="${HOME}/.secrets/pcloud"
_PCLOUD_USERNAME_FILE="${_PCLOUD_DIR}/username"
_PCLOUD_PASSWORD_FILE="${_PCLOUD_DIR}/password"

# Make sure the directory exists
[ ! -d "${_PCLOUD_DIR}" ] && mkdir -p "${_PCLOUD_DIR}"

## Load pCloud share
_pcloud_start() {
    if ! (pgrep pcloudcc >/dev/null 2>&1); then
        # Make sure the credentials exist
        if [ ! -f "${_PCLOUD_USERNAME_FILE}" ] || \
            [ ! -f ${_PCLOUD_PASSWORD_FILE} ]; then
            _error "pcloud: Missing credentials, run pcloudcc-credentials."
            return 1
        fi

        # Start pcloud
        (echo "$(_decrypt_file "${_PCLOUD_PASSWORD_FILE}")" | \
            pcloudcc -u "$(_decrypt_file "${_PCLOUD_USERNAME_FILE}")" \
            -p -s >/tmp/pcloud.log 2>&1 &
        )
        _debug "pcloud: started pcloud"
    fi
}
_autostart_add "_pcloud_start"

## Store pCloud credentials
pcloudcc-credentials() {
    # Username
    printf -- "%s: " "Username"
    read -r username
    _encrypt "${username}" > "${_PCLOUD_USERNAME_FILE}"

    # Password
    printf -- "%s: " "Password"
    read -r password
    _encrypt "${password}" > "${_PCLOUD_PASSWORD_FILE}"
}


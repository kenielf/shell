_dependency_add "gpg"

## Encrypts the content passed as an argument
_encrypt() {
    if [ -z "${1}" ]; then
        _error "encryption: missing content to encrypt"
    fi
    echo "${1}" | gpg -c
}

## Decrypts the content passed as an argument
_decrypt_file() {
    if [ -z "${1}" ]; then
        _error "encryption: missing file path to decrypt"
    fi
    gpg -dq "${1}"
}

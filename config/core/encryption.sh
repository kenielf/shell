_dependency_add "gpg"

## Encrypts the content passed as an argument
_encrypt() {
    if [ -z "${1}" ]; then
        _error "encryption: missing content to encrypt"
    fi
}

## Decrypts the content passed as an argument
_decrypt() {
    if [ -z "${1}" ]; then
        _error "encryption: missing content to decrypt"
    fi
}

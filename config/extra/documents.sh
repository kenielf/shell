_dependency_add "gs"

## Compress a pdf to a specific level
pdf_compress() {
    if [ -z "${1}" ]; then
        _error "documents: missing pdf argument"
    fi

    LEVEL=250
    if [ "${2}" ] && _is_number "${2}"; then
        LEVEL="${2}"
    fi

    gs -q \
        -dNOPAUSE -dBATCH -dSAFER -sDEVICE=pdfwrite \
        -dCompatibilityLevel=1.4 -dPDFSETTINGS=/screen \
        -dEmbedAllFonts=true -dSubsetFonts=true \
        -dColorImageDownsampleType=/Bicubic -dColorImageResolution="${LEVEL}" \
        -dGrayImageDownsampleType=/Bicubic -dGrayImageResolution="${LEVEL}" \
        -dMonoImageDownsampleType=/Bicubic -dMonoImageResolution="${LEVEL}" \
        -sOutputFile="$(echo "${1}" | sed -e 's/\.pdf$/-compressed.pdf/g')" \
        "${1}"
}
alias pdfc="pdf_compress"

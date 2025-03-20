_dependency_add "ffmpeg yt-dlp aria2c"

_ARIA2C_ARGS="--file-allocation=falloc"

# Reencodes a video so that it is compatible with whatsapp
whatsappify() {
    if [ -z "${1}" ] || [ -z "${2}" ]; then
        _error "videos: missing arguments for i/o"
        return 1
    fi

    ffmpeg -i "${1}" \
        -c:v h264 -profile:v baseline -level 3.0 -pix_fmt yuv420p -ac 2 \
        "${2}"
}

## Downloads a video at its highest found resolution
dlvid() {
    if [ -z "${1}" ]; then
        _error "videos: missing download url"
        return 1
    fi

    yt-dlp \
        -f bestvideo*+bestaudio/best --embed-thumbnail --add-metadata \
        --downloader aria2c --downloader-args="'aria2c:${_ARIA2C_ARGS}'" \
        -o '%(title)s.%(ext)s'
}

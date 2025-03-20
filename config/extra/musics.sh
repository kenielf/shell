_dependency_add "yt-dlp"

## Downloads a video at its highest found resolution
dlmp3() {
    if [ -z "${1}" ]; then
        _error "videos: missing download url"
        return 1
    fi

    yt-dlp -x \
        -f bestaudio/best --embed-thumbnail --audio-format mp3 --add-metadata \
        --downloader aria2c --downloader-args="'aria2c:${_ARIA2C_ARGS}'" \
        -o '%(title)s.%(ext)s'
}

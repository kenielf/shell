_dependency_add "ffmpeg yt-dlp aria2c mediainfo"

_ARIA2C_ARGS="--file-allocation=falloc"

_VIDEO_FORMAT_PATTERN="mkv|mp4|webm|gif"

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
        -f "bestvideo*+bestaudio/best" --embed-thumbnail --add-metadata \
        --downloader "aria2c" --downloader-args="aria2c:${_ARIA2C_ARGS}" \
        -o "%(title)s.%(ext)s" "${1}"
}

## Returns the amount of frames a video contains
_video_get_frame_count() {
    if [ -z "${1}" ]; then
        _error "videos: missing video file"
    fi

    mediainfo --Inform="Video;%FrameCount%" "${1}"
}

## Extracts the frames of a video into a special directory
extract-frames() {
    if [ -z "${1}" ]; then
        _error "videos: missing video file"
    fi

    # Make sure that the video is in fact a video
    if (echo "${1}" | tr '[:upper:]' '[:lower:]' | \
        grep -Pv "\.(${_VIDEO_FORMAT_PATTERN})$" >/dev/null 2>&1
    ); then
        _error "videos: not a valid video format to extract frames from"
    fi

    # Get the amount of frames (for 0 padding)
    pad="$(_video_get_frame_count "${1}" | tr -d '\n' | wc -c)"

    # Create the directory to hold the frames
    frames_dir="$(echo "${1}" | sed -re "s/\.(${_VIDEO_FORMAT_PATTERN})//g")-frames"
    echo "${frames_dir}"
    if [ ! -d "${frames_dir}" ]; then
        _debug "videos: creating '${frames_dir}/'"
        mkdir -p "${frames_dir}"
    fi

    # Finally, extract all the frames
    ffmpeg -i "${1}" "${frames_dir}/frame-%0${pad}d.png"
}

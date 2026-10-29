_kscfg_dependency_add "ffmpeg"

mread () {
    ffmpeg -hide_banner -loglevel error -i "$1" \
        -map 0:v? -map 0:a? -c copy -f nut pipe:1
}

mfmt () {
    case "$1" in
        mp4)
            ffmpeg -hide_banner -loglevel error -i pipe:0 \
                -map 0 -c copy -movflags +frag_keyframe+empty_moov \
                -f mp4 pipe:1
        ;;
        *)
            ffmpeg -hide_banner -loglevel error -i pipe:0 -f "$1" pipe:1
        ;;
    esac
}

mmangle () {
    ffmpeg -hide_banner -loglevel error -i \
        pipe:0 -map 0 \
        -c:v libx264 -profile:v baseline -level:v 3.0 -pix_fmt yuv420p -ac 2 \
        -f nut pipe:1
}

mnorm() {
  local I="${1:--16}"
  local TP="${2:--1.5}"
  local LRA="${3:-11}"

  ffmpeg -hide_banner -loglevel error \
    -i pipe:0 \
    -map 0:v? -map 0:a? \
    -c:v copy \
    -af "loudnorm=I=${I}:TP=${TP}:LRA=${LRA}" \
    -c:a pcm_s16le \
    -f nut pipe:1
}


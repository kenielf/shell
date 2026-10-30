_kscfg_dependency_add "ffmpeg"

# NOTE: The goal of these functions is to create a media-processing pipeline
# using Unix pipes. Instead of writing intermediate data to disk or having
# very long ffmpeg commands, each function passes its output directly to the 
# next through a pipe. FFmpeg's NUT format (1) is used as the intermediate
# container format to preserve encoded media streams between processing stages.
# The final operation converts the resulting stream into the desired output
# format: mread ${file} | ... | mfmt mp4 > out.mp4
#
# 1: https://ffmpeg.org/nut.html

if [ "${_SHELL_DEBUG}" = 1 ]; then
    _KSCFG_MPIPELINE_ARGS="-hide_banner -loglevel info"
else
    _KSCFG_MPIPELINE_ARGS="-hide_banner -loglevel error"
fi

mread () {
    ffmpeg ${_KSCFG_MPIPELINE_ARGS} -i "$1" \
        -map 0:v? -map 0:a? -c copy -f nut pipe:1
}

mfmt () {
    # FIXME: Removes metadata - might be nice to see this again later
    local extra
    local format="${1}"
    case "${format}" in
        mp3) extra="-map 0:a:0 -vn -c:a libmp3lame" ;;
        mp4) extra="-map 0 -c copy -movflags +frag_keyframe+empty_moov" ;;
        mkv) format="matroska"; extra="-map 0 -c copy" ;;
        *) extra="-map 0 -c copy" ;;
    esac

    ffmpeg ${_KSCFG_MPIPELINE_ARGS} \
        -i pipe:0 -map_metadata -1 ${extra} \
        -f ${format} pipe:1
}

mcut() {
    # NOTE: Buffers the entire incoming NUT stream before trimming it.
    # SS defines the starting timestamp, while TO defines the ending timestamp.
    local SS="${1:-00:00:00}"
    local TO="${2:-00:00:00}"
    local INPUT
    INPUT="$(mktemp)" || return 1

    cat > "${INPUT}" || {
        rm -f "${INPUT}"
        return 1
    }

    ffmpeg ${_KSCFG_MPIPELINE_ARGS} \
        -i "${INPUT}" \
        -ss "${SS}" -to "${TO}" \
        -map 0 -c copy \
        -f nut pipe:1

    local STATUS=$?
    rm -f "${INPUT}"
    return "${STATUS}"
}

mmangle () {
    # NOTE: This function re-encodes the media using conservative encoding
    # settings to maximize compatibility with platforms that enforce strict
    # media format requirements (e.g. WhatsApp). This includes using H.264
    # Baseline Profile, Level 3.0, and YUV420p for video, alongside stereo
    # audio.
    ffmpeg ${_KSCFG_MPIPELINE_ARGS} \
        -i pipe:0 -map 0 \
        -c:v libx264 -profile:v baseline -level:v 3.0 -pix_fmt yuv420p -ac 2 \
        -f nut pipe:1
}

mnorm() {
    # NOTE: Applies EBU R128 loudness normalization to the audio stream.
    # Integrated Loudness (I): target average perceived loudness in LUFS.
    # True Peak (TP): maximum allowed peak level in dBTP to prevent clipping.
    # Loudness Range (LRA): target dynamic range in LU, controlling
    # how much variation in loudness is preserved throughout the audio.
    # Video streams are copied unchanged, while audio is converted to PCM
    # for further processing within the pipeline.
    local I="${1:--16}"
    local TP="${2:--1.5}"
    local LRA="${3:-11}"

    ffmpeg ${_KSCFG_MPIPELINE_ARGS} \
      -i pipe:0 -map 0:v? -map 0:a? -c:v copy \
      -af "loudnorm=I=${I}:TP=${TP}:LRA=${LRA}" -c:a pcm_s16le \
      -f nut pipe:1
}

mcomp() {
    # NOTE: Re-encodes the video stream using H264 + CRF (Constant Rate Factor)
    # to control the quality-to-file-size trade-off. Lower CRF values produce
    # higher visual quality and larger files, while higher values produce
    # smaller files at the expense of quality.
    local CRF="${1:-23}"

    ffmpeg ${_KSCFG_MPIPELINE_ARGS} \
      -i pipe:0 -map 0:v? -map 0:a? -c:a copy \
      -crf "${CRF}" \
      -f nut pipe:1
}

mresize() {
    # NOTE: Resizes the video stream to the specified width and height (WxH)
    # using FFmpeg's scale filter. Either dimension can be set to -1 to
    # automatically preserve the input aspect ratio.
    local SIZE="${1:?Usage: mresize WxH}"

    ffmpeg ${_KSCFG_MPIPELINE_ARGS} \
      -i pipe:0 -map 0:v? -map 0:a? -c:a copy \
      -vf "scale=${SIZE/:/x}" \
      -f nut pipe:1
}


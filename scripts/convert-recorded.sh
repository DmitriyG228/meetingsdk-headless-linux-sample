#!/usr/bin/env bash
# Convert raw recording outputs to playable files.
# - meeting-audio.pcm (raw PCM) -> meeting-audio.wav
# - Optionally: meeting-video.mp4 + meeting-audio.wav -> meeting-with-audio.mp4
#
# Usage:
#   ./scripts/convert-recorded.sh
#   ./scripts/convert-recorded.sh 32000   # if Zoom used 32kHz (try if 16k sounds wrong)

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
OUT="$REPO_ROOT/out"
SAMPLE_RATE="${1:-32000}"

if ! command -v ffmpeg &>/dev/null; then
  echo "Error: ffmpeg is required. Install with: brew install ffmpeg" >&2
  exit 1
fi

# Raw PCM from Zoom SDK is 16-bit signed LE, mono. Default 32 kHz matches Zoom mixed audio.
# If too fast try 16000; if too slow try 48000.
if [[ -f "$OUT/meeting-audio.pcm" ]]; then
  echo "Converting meeting-audio.pcm -> meeting-audio.wav (${SAMPLE_RATE} Hz, mono, s16le)"
  ffmpeg -y -f s16le -ar "$SAMPLE_RATE" -ac 1 -i "$OUT/meeting-audio.pcm" "$OUT/meeting-audio.wav"
  echo "Created $OUT/meeting-audio.wav"
fi

# Per-speaker tracks (when run with --separate-participants or [RawAudio] separate-participants=true)
had_audio=false
[[ -f "$OUT/meeting-audio.pcm" ]] && had_audio=true
for pcm in "$OUT"/node-*.pcm; do
  [[ -e "$pcm" ]] || continue
  had_audio=true
  base=$(basename "$pcm" .pcm)
  echo "Converting $base.pcm -> $base.wav (${SAMPLE_RATE} Hz, mono, s16le)"
  ffmpeg -y -f s16le -ar "$SAMPLE_RATE" -ac 1 -i "$pcm" "$OUT/$base.wav"
  echo "Created $OUT/$base.wav"
done
if [[ "$had_audio" != true ]]; then
  echo "No $OUT/meeting-audio.pcm or $OUT/node-*.pcm found. Run a recording first." >&2
fi

if [[ -f "$OUT/meeting-video.mp4" && -f "$OUT/meeting-audio.wav" ]]; then
  echo "Muxing video + audio -> meeting-with-audio.mp4"
  ffmpeg -y -i "$OUT/meeting-video.mp4" -i "$OUT/meeting-audio.wav" -c:v copy -c:a aac -shortest "$OUT/meeting-with-audio.mp4"
  echo "Created $OUT/meeting-with-audio.mp4"
fi

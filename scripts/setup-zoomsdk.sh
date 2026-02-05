#!/usr/bin/env bash
# Setup Zoom Meeting SDK for Linux in lib/zoomsdk/
# Usage:
#   ./scripts/setup-zoomsdk.sh                    # show instructions and open download page
#   ./scripts/setup-zoomsdk.sh path/to/sdk.tar    # extract archive into lib/zoomsdk
#   ZOOM_SDK_ARCHIVE=path/to/sdk.tar ./scripts/setup-zoomsdk.sh

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
ZOOM_SDK_DIR="$REPO_ROOT/lib/zoomsdk"
DOWNLOAD_URL="https://marketplace.zoom.us/user/build"

archive="${1:-$ZOOM_SDK_ARCHIVE}"

if [[ -f "$ZOOM_SDK_DIR/libmeetingsdk.so" ]]; then
  echo "Zoom SDK already present at $ZOOM_SDK_DIR"
  exit 0
fi

if [[ -n "$archive" && -f "$archive" ]]; then
  echo "Extracting Zoom SDK from $archive ..."
  tmp=$(mktemp -d)
  trap "rm -rf $tmp" EXIT
  if [[ "$archive" == *.zip ]]; then
    unzip -q "$archive" -d "$tmp"
  else
    tar -xf "$archive" -C "$tmp"
  fi
  # Find the directory that contains libmeetingsdk.so (may be top-level or one level down)
  found=
  for dir in "$tmp" "$tmp"/*/; do
    [[ -f "${dir%/}/libmeetingsdk.so" ]] && { found="${dir%/}"; break; }
  done
  if [[ -z "$found" ]]; then
    echo "Error: libmeetingsdk.so not found inside archive. Check the archive structure." >&2
    exit 1
  fi
  mkdir -p "$ZOOM_SDK_DIR"
  cp -R "${found%/}/." "$ZOOM_SDK_DIR/"
  echo "Zoom SDK installed to $ZOOM_SDK_DIR"
  exit 0
fi

# No archive or SDK missing: show instructions and open download page
echo ""
echo "Zoom Meeting SDK for Linux is required and was not found at:"
echo "  $ZOOM_SDK_DIR"
echo ""
echo "Steps:"
echo "  1. Open the Zoom Marketplace (building your app):"
echo "     $DOWNLOAD_URL"
echo "  2. Select your Meeting SDK app (or create one)."
echo "  3. Open the 'Download' tab and download the Linux SDK (e.g. zoom-meeting-sdk-linux_x86_64-*.tar or .tar.gz)."
echo "  4. Run this script with the path to the downloaded file:"
echo "     ./scripts/setup-zoomsdk.sh ~/Downloads/zoom-meeting-sdk-linux_x86_64-5.x.x.x.tar"
echo "     Or: ZOOM_SDK_ARCHIVE=~/Downloads/zoom-meeting-sdk-linux_xxx.tar ./scripts/setup-zoomsdk.sh"
echo ""
if [[ -n "$archive" ]]; then
  echo "Error: Archive not found: $archive" >&2
  exit 1
fi

# Open download page in browser on macOS
if command -v open >/dev/null 2>&1; then
  open "$DOWNLOAD_URL"
  echo "Opened Zoom Marketplace in your browser."
fi
exit 1

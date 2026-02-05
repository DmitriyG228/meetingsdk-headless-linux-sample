#!/usr/bin/env bash

# directory for CMake output (use /tmp/build in Docker to avoid host cache issues)
if [[ -f /.dockerenv ]]; then
  BUILD=/tmp/build
else
  BUILD=build
fi

# directory for application output
mkdir -p out

setup-pulseaudio() {
  # Enable dbus
  if [[  ! -d /var/run/dbus ]]; then
    mkdir -p /var/run/dbus
    dbus-uuidgen > /var/lib/dbus/machine-id
    dbus-daemon --config-file=/usr/share/dbus-1/system.conf --print-address
  fi

  usermod -G pulse-access,audio root

  # Cleanup to be "stateless" on startup, otherwise pulseaudio daemon can't start
  rm -rf /var/run/pulse /var/lib/pulse /root/.config/pulse/
  mkdir -p ~/.config/pulse/ && cp -r /etc/pulse/* "$_"

  pulseaudio -D --exit-idle-time=-1 --system --disallow-exit

  # Create a virtual speaker output

  pactl load-module module-null-sink sink_name=SpeakerOutput
  pactl set-default-sink SpeakerOutput
  pactl set-default-source SpeakerOutput.monitor

  # Make config file
  echo -e "[General]\nsystem.audio.type=default" > ~/.config/zoomus.conf
}

build() {
  # Configure CMake if build dir missing or no cache (e.g. fresh volume)
  if [[ ! -d "$BUILD" ]] || [[ ! -f "$BUILD/CMakeCache.txt" ]]; then
    cmake -B "$BUILD" -S . --preset debug || exit
    [[ -d client && -n "$(command -v npm)" ]] && npm --prefix=client install || true
  fi

  # Check Zoom SDK is present (download from Zoom Marketplace and place in lib/zoomsdk)
  LIB="lib/zoomsdk/libmeetingsdk.so"
  if [[ ! -f "$LIB" ]]; then
    echo "Error: Zoom SDK not found at $LIB" >&2
    echo "On your host machine, run: ./scripts/setup-zoomsdk.sh" >&2
    echo "Or extract the Zoom Linux SDK archive into lib/zoomsdk/ (see https://developers.zoom.us/docs/meeting-sdk/linux/)" >&2
    exit 1
  fi
  [[ ! -f "${LIB}.1" ]] && cp "$LIB"{,.1}

  # Set up and start pulseaudio
  setup-pulseaudio &> /dev/null || exit;

  # Build the Source Code
  cmake --build "$BUILD"
}

run() {
    export QT_LOGGING_RULES="*.debug=false;*.warning=false"
    exe="${BUILD}/zoomsdk"
    if [[ -f config.toml ]]; then
      exec "$exe" --config config.toml "$@"
    else
      exec "$exe" "$@"
    fi
}

build && run;

exit $?


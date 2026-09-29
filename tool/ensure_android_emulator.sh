#!/usr/bin/env bash
# Start the hapopay AVD if no Android emulator is already connected.
set -euo pipefail

export JAVA_HOME="${JAVA_HOME:-$HOME/Android/jdk}"
export ANDROID_HOME="${ANDROID_HOME:-$HOME/Android/Sdk}"
export ANDROID_SDK_ROOT="${ANDROID_SDK_ROOT:-$ANDROID_HOME}"
export ANDROID_USER_HOME="${ANDROID_USER_HOME:-$HOME/.config/.android}"
export ANDROID_AVD_HOME="${ANDROID_AVD_HOME:-$HOME/.config/.android/avd}"
export PATH="$JAVA_HOME/bin:$ANDROID_HOME/cmdline-tools/latest/bin:$ANDROID_HOME/platform-tools:$ANDROID_HOME/emulator:$PATH"
export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-xcb}"

AVD_NAME="${HAPOPAY_AVD:-hapopay}"
ADB="${ANDROID_HOME}/platform-tools/adb"
EMU="${ANDROID_HOME}/emulator/emulator"

if ! "$ADB" devices 2>/dev/null | awk 'NR>1 && $2=="device" && $1 ~ /^emulator-/' | grep -q .; then
  if ! "$EMU" -list-avds 2>/dev/null | grep -qx "$AVD_NAME"; then
    echo "Android emulator '$AVD_NAME' was not found. Create it first (see docs/SETUP.md)." >&2
    exit 1
  fi
  echo "Starting Android emulator '$AVD_NAME'..."
  "$EMU" -avd "$AVD_NAME" -netdelay none -netspeed full -gpu auto -no-metrics \
    >/tmp/hapopay-emulator.log 2>&1 &
  disown || true
fi

"$ADB" wait-for-device

for _ in $(seq 1 90); do
  if [[ "$("$ADB" shell getprop sys.boot_completed 2>/dev/null | tr -d '\r')" == "1" ]]; then
    echo "Android emulator is ready."
    exit 0
  fi
  sleep 2
done

echo "Android emulator did not finish booting. Last log: /tmp/hapopay-emulator.log" >&2
exit 1

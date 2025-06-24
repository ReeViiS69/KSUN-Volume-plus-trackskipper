#!/system/bin/sh
CONFIG_FILE="/data/adb/.config/volume_skip/ig.conf"

if [ -f "$CONFIG_FILE" ]; then
  . "$CONFIG_FILE"
else
  exit 1
fi

is_display_on() {
  [ -n "$DISPLAY_VAR" ] && dumpsys power | grep "$DISPLAY_VAR" | grep -q "$DISPLAY_EXPECT"
}

start_ts=""

getevent -t -l "$VOLUME_DEVICE" | while read -r line; do
  if echo "$line" | grep -q "KEY_VOLUMEUP.*DOWN"; then
    start_ts=$(date +%s%3N)
  fi

  if echo "$line" | grep -q "KEY_VOLUMEUP.*UP"; then
    if [ -n "$start_ts" ]; then
      end_ts=$(date +%s%3N)
      delta=$((end_ts - start_ts))
      if [ "$delta" -ge "$LONG_PRESS_MS" ]; then
        if ! is_display_on; then
          input keyevent 25
          input keyevent 87
        fi
      fi
    fi
    start_ts=""
  fi
done &

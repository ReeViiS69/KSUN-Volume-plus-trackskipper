#!/system/bin/sh
CONFIG_FILE="/data/adb/.config/volume_skip/ig.conf"
if [ -z ${LOADED+x} ]; then
if [ -f "$CONFIG_FILE" ]; then
    . "$CONFIG_FILE"
    LOADED="1"
else
  exit 1
fi
fi
start_ts=""

getevent -t -l "$VOLUME_DEVICE" | awk -v long_press="$LONG_PRESS_MS" -v dvar="$DISPLAY_VAR" -v dexp="$DISPLAY_EXPECT" '
/KEY_VOLUMEUP.*DOWN/ {
    display_on = (system("dumpsys power | grep \"" dvar "\" | grep -q \"" dexp "\"") == 0)
    if (!display_on) {
        "date +%s%3N" | getline start_ts
        close("date +%s%3N")
    }
  }
  /KEY_VOLUMEUP.*UP/ {
    if (start_ts != "") {
        "date +%s%3N" | getline end_ts
        close("date +%s%3N")
        delta = end_ts - start_ts
        if (delta >= long_press) {
          system("input keyevent 25")
          system("input keyevent 87")
        }
    }
    start_ts = ""
  }
'

#!/system/bin/sh

CONFIG_FILE="/data/adb/.config/volume_skip/ig.conf"
mkdir /data/adb/.config/volume_skip

for dev in /dev/input/event*; do
  if getevent -il "$dev" 2>/dev/null | grep -q "KEY_VOLUMEUP"; then
    echo "VOLUME_DEVICE=$dev" > "$CONFIG_FILE"
    break
  fi
done

if dumpsys power | grep -q "Display Power: state=ON"; then
  echo "DISPLAY_VAR='Display Power: state'" >> "$CONFIG_FILE"
  echo "DISPLAY_EXPECT='ON'" >> "$CONFIG_FILE"
elif dumpsys power | grep -q "mScreenOn=true"; then
  echo "DISPLAY_VAR='mScreenOn'" >> "$CONFIG_FILE"
  echo "DISPLAY_EXPECT='true'" >> "$CONFIG_FILE"
elif dumpsys power | grep -q "mWakefulness=Awake"; then
  echo "DISPLAY_VAR='mWakefulness'" >> "$CONFIG_FILE"
  echo "DISPLAY_EXPECT='Awake'" >> "$CONFIG_FILE"
else
  echo "DISPLAY_VAR=''" >> "$CONFIG_FILE"
  echo "DISPLAY_EXPECT=''" >> "$CONFIG_FILE"
fi

echo "Konfiguration gespeichert in $CONFIG_FILE"

#!/system/bin/sh

export PATH=/system/bin:/system/xbin:$PATH
LONG_PRESS_MS=600
LOG="/data/local/tmp/volume_skip.log"
cur_vol=""

log() {
  echo "[$(date '+%F %T')] $1" >> "$LOG"
}

# Suche das Input-Gerät mit VolumeUp
find_volume_device() {
  for dev in /dev/input/event*; do
    if getevent -il "$dev" 2>/dev/null | grep -q "KEY_VOLUMEUP"; then
      echo "$dev"
      return
    fi
  done
}

# Displaystatus prüfen (robust)
is_display_on() {
  dumpsys power | grep -E 'Display Power|mScreenOn|mWakefulness' | grep -qE 'state=ON|mScreenOn=true|mWakefulness=Awake'
}

DEVICE=$(find_volume_device)
if [ -z "$DEVICE" ]; then
  log "Kein VolumeUp-Device gefunden!"
  exit 1
fi

log "Überwache VolumeUp auf $DEVICE"

start_ts=""

getevent -t -l "$DEVICE" | while read -r line; do
  if echo "$line" | grep -q "KEY_VOLUMEUP.*DOWN"; then
    start_ts=$(date +%s%3N)
    log "VolumeUp DOWN erkannt"
  fi

  if echo "$line" | grep -q "KEY_VOLUMEUP.*UP"; then
    if [ -n "$start_ts" ]; then
      end_ts=$(date +%s%3N)
      delta=$((end_ts - start_ts))
      if [ "$delta" -ge "$LONG_PRESS_MS" ]; then
        if ! is_display_on; then
		  input keyevent 25
          input keyevent 87
          log "Track Skip + Lautstärke zurückgesetzt(${delta}ms, Display OFF)"
        else
          log "Langdruck erkannt, aber Display AN (${delta}ms)"
        fi
      fi
    fi
    start_ts=""
  fi
done &

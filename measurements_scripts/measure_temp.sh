#!/bin/bash
# Usage: sudo ./cpu_temp_logger.sh <interval_sec> <duration_sec>

INTERVAL=${1:-1}
DURATION=${2:-10}
OUTPUT="data/cpu_temp.csv"

# Find coretemp hwmon
HWMON=$(grep -l coretemp /sys/class/hwmon/hwmon*/name | sed 's|/name||')

if [[ -z "$HWMON" ]]; then
    echo "coretemp hwmon not found"
    exit 1
fi

# Find Package temperature
TEMP_FILE=$(grep -l "Package id 0" $HWMON/temp*_label | sed 's/_label/_input/')

if [[ -z "$TEMP_FILE" ]]; then
    echo "Package temperature not found"
    exit 1
fi

echo "timestamp,cpu_temp_c" > "$OUTPUT"

SAMPLES=$(awk "BEGIN {print int($DURATION / $INTERVAL)}")

for ((i=0; i<SAMPLES; i++)); do
    RAW=$(cat "$TEMP_FILE")
    TEMP=$(awk "BEGIN {printf \"%.3f\", $RAW / 1000}")

    echo "$(date +%s),$TEMP" >> "$OUTPUT"
    sleep "$INTERVAL"
done

echo "Done. CSV saved to $OUTPUT"
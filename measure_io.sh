#!/bin/bash
# io_power_logger.sh
# Logs I/O activity (read+write bytes) over time as a proxy for disk power

INTERVAL=1      # seconds between samples
DURATION=10     # total duration
OUTPUT="io_power.csv"
DEVICE="sda"    # your block device (e.g., sda, nvme0n1)

echo "timestamp,read_kB,write_kB,total_kB" > "$OUTPUT"

NUM_SAMPLES=$((DURATION / INTERVAL))
for ((i=0; i<NUM_SAMPLES; i++)); do
    # read initial stats
    read_prev=$(cat /sys/block/$DEVICE/stat | awk '{print $3}')    # sectors read
    write_prev=$(cat /sys/block/$DEVICE/stat | awk '{print $7}')   # sectors written

    sleep $INTERVAL

    read_now=$(cat /sys/block/$DEVICE/stat | awk '{print $3}')
    write_now=$(cat /sys/block/$DEVICE/stat | awk '{print $7}')

    # compute delta in kB (sector = 512 bytes)
    read_kB=$(( (read_now - read_prev) * 512 / 1024 ))
    write_kB=$(( (write_now - write_prev) * 512 / 1024 ))
    total_kB=$((read_kB + write_kB))

    echo "$(date +%s),$read_kB,$write_kB,$total_kB" >> "$OUTPUT"
done

echo "Done. CSV saved to $OUTPUT"

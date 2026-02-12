#!/bin/bash
# nic_power_logger.sh
# Logs NIC activity over time as a proxy for NIC power

INTERVAL=${1:-1}      # seconds between samples
DURATION=${2:-10}     # total duration
OUTPUT="data/nic_power.csv"
IFACE="eno1"

echo "timestamp,rx_bytes,tx_bytes,total_bytes" > "$OUTPUT"

NUM_SAMPLES=$((DURATION / INTERVAL))
for ((i=0; i<NUM_SAMPLES; i++)); do
    # read initial stats
    rx_prev=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
    tx_prev=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)

    sleep $INTERVAL

    rx_now=$(cat /sys/class/net/$IFACE/statistics/rx_bytes)
    tx_now=$(cat /sys/class/net/$IFACE/statistics/tx_bytes)

    # delta bytes
    rx_delta=$((rx_now - rx_prev))
    tx_delta=$((tx_now - tx_prev))
    total=$((rx_delta + tx_delta))

    echo "$(date +%s),$rx_delta,$tx_delta,$total" >> "$OUTPUT"
done

echo "Done. CSV saved to $OUTPUT"

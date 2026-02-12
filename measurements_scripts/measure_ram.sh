#!/bin/bash
# rapl_ram_logger.sh
# Logs RAM power (DRAM domain) to CSV over a specified interval
# Requires root

# -----------------------------
# Configurable parameters
# -----------------------------
INTERVAL=${1:-1}      # seconds between samples
DURATION=${2:-10}     # total duration
OUTPUT="data/ram_power.csv"

DOMAIN="/sys/class/powercap/intel-rapl:0:1/energy_uj"

# -----------------------------
# Check root
# -----------------------------
if [[ $EUID -ne 0 ]]; then
    echo "Please run as root"
    exit 1
fi

# -----------------------------
# Check RAPL domain exists
# -----------------------------
if [[ ! -f "$DOMAIN" ]]; then
    echo "DRAM RAPL domain not found at $DOMAIN"
    exit 1
fi

# -----------------------------
# Initialize CSV
# -----------------------------
echo "timestamp,ram_power_w" > "$OUTPUT"

# -----------------------------
# Sampling loop
# -----------------------------
NUM_SAMPLES=$(( DURATION / INTERVAL ))
for ((i=0; i<NUM_SAMPLES; i++)); do
    # read start energy
    E_START=$(cat $DOMAIN)
    T_START=$(date +%s)

    sleep $INTERVAL

    # read end energy
    E_END=$(cat $DOMAIN)
    T_END=$(date +%s)

    # compute power (Watts)
    # delta energy in Joules
    DELTA_J=$((E_END - E_START))
    POWER=$(echo "scale=4; $DELTA_J / 1000000 / $INTERVAL" | bc -l)

    # log CSV
    echo "$T_END,$POWER" >> "$OUTPUT"
done

echo "Done. CSV saved to $OUTPUT"

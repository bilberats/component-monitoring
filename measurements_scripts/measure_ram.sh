#!/bin/bash
# rapl_ram_logger.sh
# Logs RAM power (DRAM domain) to CSV over a specified interval
# Requires root

# -----------------------------
# Configurable parameters
# -----------------------------
#!/bin/bash

# Usage: ./log_llc.sh <interval_sec> <duration_sec> <output.csv>
INTERVAL=${1:-1}      # seconds between samples, default 1s
DURATION=${2:-10}     # total duration, default 10s
OUTPUT="data/ram_power.csv"  # output CSV file, default llc_log.csv

echo "Timestamp,LLC-loads,LLC-stores" > "$OUTPUT"

# Calculate number of iterations
ITERATIONS=$((DURATION / INTERVAL))

for ((i=0; i<ITERATIONS; i++)); do
    TIMESTAMP=$(date +%s)

    # Capture LLC-loads and LLC-stores system-wide for 1 interval
    PERF_OUTPUT=$(perf stat -a -e LLC-loads,LLC-stores sleep "$INTERVAL" 2>&1)

    # Extract the counts
    LLC_LOADS=$(echo "$PERF_OUTPUT" | grep LLC-loads | awk '{print $1}' | tr -d ',')
    LLC_STORES=$(echo "$PERF_OUTPUT" | grep LLC-stores | awk '{print $1}' | tr -d ',')

    # Append to CSV
    echo "$TIMESTAMP,$LLC_LOADS,$LLC_STORES" >> "$OUTPUT"
done

echo "Logging complete. CSV saved to $OUTPUT"


#!/bin/bash
# Launch all measurement scripts concurrently

set -e

INTERVAL=${1:-1}      # seconds between samples
DURATION=${2:-10}     # total duration

SCRIPTS=(
  "./measurements_scripts/measure_cpu.sh"
  "./measurements_scripts/measure_io.sh"
  "./measurements_scripts/measure_nic.sh"
  "./measurements_scripts/measure_ram.sh"
)

PIDS=()

echo "Starting measurements at $(date)"


for script in "${SCRIPTS[@]}"; do
    echo "Launching $script"
    sudo bash "$script" "$INTERVAL" "$DURATION" &
    PIDS+=($!)
done

trap 'echo "Stopping..."; kill ${PIDS[*]} 2>/dev/null' SIGINT

# Wait for all scripts to finish
for pid in "${PIDS[@]}"; do
    wait "$pid"
done

echo "All measurements completed at $(date)"

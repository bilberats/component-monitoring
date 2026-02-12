#!/bin/bash
# Start all measurements in DNS PC and monitorin PC for both external and internal measures simultaneously

INTERVAL=${1:-1}      # seconds between samples
DURATION=${2:-10}     # total duration

echo "Starting measurements at $(date +%s.%N)"

# May requires password for the first execution (depends on ssh configuration)
ssh thd@157.159.55.165 "cd ~/component-monitoring && bash ./orchestrate_measures.sh $INTERVAL $DURATION" &

SSH_PID=$!

# Launch local power meter
python3 yoctowatt_log_fast.py --seconds "$DURATION" &

LOCAL_PID=$!

# Wait for both to finish
wait $SSH_PID
wait $LOCAL_PID

echo "Measurements completed at $(date +%s.%N)"
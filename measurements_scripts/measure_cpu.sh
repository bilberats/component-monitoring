#!/bin/bash
# turbostat_loop.sh
# Nécessite d'être lancé en root

INTERVAL=${1:-1}      # seconds between samples
DURATION=${2:-10}     # total duration
OUTPUT="data/cpu_power.csv"

turbostat -i $INTERVAL -n $DURATION --quiet -S --show Time_Of_Day_Seconds,TSC_MHz,C1%,C3%,C6%,NMI  | awk '{$1=$1}1' OFS=, > $OUTPUT

echo "Done. CSV saved to $OUTPUT"
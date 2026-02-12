#!/bin/bash
# turbostat_loop.sh
# Nécessite d'être lancé en root

INTERVAL=${1:-1}      # seconds between samples
DURATION=${2:-10}     # total duration
OUTPUT="data/cpu_power.csv"

sudo turbostat -i $INTERVAL -n $DURATION --quiet -S --show Time_Of_Day_Seconds,PkgWatt,CorWatt,Busy%,Bzy_MHz,Avg_MHz,C6% | awk '{$1=$1}1' OFS=, > $OUTPUT

echo "Done. CSV saved to $OUTPUT"
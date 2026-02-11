#!/bin/bash
# turbostat_loop.sh
# Nécessite d'être lancé en root

INTERVAL=1
DURATION=1
OUTPUT_FILE="turbostat_output.csv"

turbostat -i $INTERVAL -n $DURATION --quiet -S | awk '{$1=$1}1' OFS=, > $OUTPUT_FILE
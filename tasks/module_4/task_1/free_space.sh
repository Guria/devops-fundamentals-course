#!/usr/bin/env bash

# Set default values for wait interval and threshold
WAIT_INTERVAL=${WAIT_INTERVAL:-5}
THRESHOLD=${THRESHOLD:-2}
RUN_ONCE=1

# Parse command line options
while getopts "iw:t:" opt; do
  case $opt in
    i) RUN_ONCE=0;;
    w) WAIT_INTERVAL=$OPTARG;;
    t) THRESHOLD=$OPTARG;;
    \?) echo "Invalid option -$OPTARG" >&2; exit 1;;
  esac
done

check_space() {
  FREE_SPACE=$(df -B 1G --output=avail / | awk 'NR==2 {print $1}')
  echo "Free space: $FREE_SPACE GB"
  if (( $(echo "$FREE_SPACE < $THRESHOLD" | bc -l) )); then
    echo "WARNING: Free space is less than ${THRESHOLD}GB"
    false
  else
    true
  fi
}

# Run the function once or indefinitely based on the RUN_ONCE flag
if [ $RUN_ONCE -eq 1 ]; then
  check_space
  exit $?
else
  while true; do
    check_space
    sleep $WAIT_INTERVAL
  done
fi

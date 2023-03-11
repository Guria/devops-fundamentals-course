#!/usr/bin/env bash

total=0
for dir in "$@"; do
  count=$(find "$dir" -type f | wc -l)
  echo "$dir: $count files"
  total=$((total + count))
done

echo "Total: $total files"


#!/usr/bin/env bash

# Determine the directory of the test script
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

# Create a temporary directory for testing
TEST_DIR=$(mktemp -d)

# Clean up the temporary directory on exit, regardless of test results
function cleanup {
  rm -rf "$TEST_DIR"
}
trap cleanup EXIT

# Test case 1: Running the script without any options or arguments
output=$(bash "$SCRIPT_DIR/free_space.sh")
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "Test case 1 failed: script exited with non-zero code $exit_code"
  exit 1
fi
if [[ $output != "Free space: "* ]]; then
  echo "Test case 1 failed: output did not contain expected free space value"
  exit 1
fi

# Test case 2: Specifying a threshold value and checking that the script exits with an error code when free space is below the threshold
output=$(bash "$SCRIPT_DIR/free_space.sh" -t 100000)
exit_code=$?
if [ $exit_code -eq 0 ]; then
  echo "Test case 2 failed: script did not exit with error code when free space was below threshold"
  exit 1
fi

# Test case 3: Specifying a threshold value and checking that the script does not exit with an error code when free space is above the threshold
output=$(bash "$SCRIPT_DIR/free_space.sh" -t 1)
exit_code=$?
if [ $exit_code -ne 0 ]; then
  echo "Test case 3 failed: script exited with non-zero code when free space was above threshold"
  exit 1
fi

# Test case 4: Specifying the -i option and checking that the script runs indefinitely
output=$(timeout 7 bash "$SCRIPT_DIR/free_space.sh" -i)
exit_code=$?
if [ $(echo "$output" | grep "Free space:" | wc -l) -lt 2 ]; then
  echo "Test case 4 failed: output did not contain expected number of lines"
  exit 1
fi

# Test case 5: Specifying the -i option with custom -w value and checking that the script runs indefinitely
output=$(timeout 5 bash "$SCRIPT_DIR/free_space.sh" -i -w 2)
exit_code=$?
if [ $(echo "$output" | grep "Free space:" | wc -l) -lt 3 ]; then
  echo "Test case 5 failed: output did not contain expected number of lines"
  exit 1
fi

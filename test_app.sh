#!/bin/bash
# Simple Android app test script.
# Usage: ./test_app.sh <apk_path> <package_name>
# This script installs an APK on a connected Android device, launches it once, waits a few
# seconds to allow any crash to occur, then dumps the logcat output to a file for analysis.

set -e

APK_PATH="$1"
PACKAGE_NAME="$2"

if [ -z "$APK_PATH" ] || [ -z "$PACKAGE_NAME" ]; then
  echo "Usage: $0 <apk_path> <package_name>"
  echo "Example: $0 app-debug.apk com.example.myapp"
  exit 1
fi

# Check for connected devices
DEVICE=$(adb devices | sed -n '2p' | cut -f1)
if [ -z "$DEVICE" ]; then
  echo "No connected Android device found. Please connect a device or start an emulator."
  exit 1
fi

echo "Installing $APK_PATH on device $DEVICE..."
adb -s "$DEVICE" install -r "$APK_PATH"

echo "Clearing existing logcat logs..."
adb -s "$DEVICE" logcat -c

echo "Launching the app ($PACKAGE_NAME) once using monkey..."
adb -s "$DEVICE" shell monkey -p "$PACKAGE_NAME" -v 1

# Wait briefly to allow the app to start and potentially crash
sleep 5

LOG_FILE="crash_log_$(date +%Y%m%d_%H%M%S).txt"
echo "Collecting logcat output to $LOG_FILE..."
adb -s "$DEVICE" logcat -d > "$LOG_FILE"

echo "Test completed. Log saved to $LOG_FILE."
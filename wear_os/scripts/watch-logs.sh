#!/bin/bash

# Watch Logs Script for Rectran Wear OS
# Monitors logcat for Rectran-related logs

echo "👀 Watching Rectran logs... (Ctrl+C to stop)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

adb logcat | grep --color=always -E "Rectran|SAP|MediaRecorder|AudioReceiver"

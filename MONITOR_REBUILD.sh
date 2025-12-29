#!/bin/bash
# Quick script to monitor rebuild progress

echo "📊 Monitoring rebuild progress..."
echo "Press Ctrl+C to stop monitoring"
echo ""

while true; do
  if [ -f /tmp/rebuild.log ]; then
    clear
    echo "📊 Rebuild Progress (last 15 lines):"
    echo "=================================="
    tail -15 /tmp/rebuild.log 2>/dev/null
    echo ""
    echo "⏰ $(date '+%H:%M:%S') - Still building..."
  else
    echo "⏳ Waiting for rebuild to start..."
  fi
  sleep 5
done






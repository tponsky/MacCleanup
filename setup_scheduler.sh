#!/bin/bash
# Setup scheduled automatic cleanup

PLIST_PATH="$HOME/Library/LaunchAgents/com.maccleanup.auto.plist"
SCRIPT_PATH="$(cd "$(dirname "$0")" && pwd)/auto_cleanup.py"
PYTHON_PATH="$(cd "$(dirname "$0")" && pwd)/venv/bin/python3"

echo "🔧 Setting up MacCleanup scheduler..."

# Create the LaunchAgent plist
cat > "$PLIST_PATH" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.maccleanup.auto</string>
    <key>ProgramArguments</key>
    <array>
        <string>$PYTHON_PATH</string>
        <string>$SCRIPT_PATH</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>9</integer>
        <key>Minute</key>
        <integer>0</integer>
        <key>Weekday</key>
        <integer>1</integer>
    </dict>
    <key>StandardOutPath</key>
    <string>/tmp/maccleanup.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/maccleanup.error.log</string>
</dict>
</plist>
EOF

# Load the LaunchAgent
launchctl unload "$PLIST_PATH" 2>/dev/null
launchctl load "$PLIST_PATH"

echo "✅ Scheduler installed!"
echo "   MacCleanup will run automatically every Monday at 9:00 AM"
echo ""
echo "   To change the schedule, edit: $PLIST_PATH"
echo "   To disable: launchctl unload $PLIST_PATH"
echo "   To run now: $PYTHON_PATH $SCRIPT_PATH"

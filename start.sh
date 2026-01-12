#!/bin/bash
# MacCleanup Launcher
# Double-click this to start the cleanup web app

cd "$(dirname "$0")"

# Check if virtual environment exists, create if not
if [ ! -d "venv" ]; then
    echo "Setting up MacCleanup for first time..."
    python3 -m venv venv
    source venv/bin/activate
    pip install -q flask watchdog schedule
else
    source venv/bin/activate
fi

# Open browser after a short delay
(sleep 2 && open "http://localhost:5050") &

# Run the app
echo "🧹 Starting MacCleanup..."
python3 app.py

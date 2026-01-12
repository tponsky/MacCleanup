#!/bin/bash
# Create a DMG installer for MacCleanup

APP_NAME="MacCleanup"
VERSION="1.0"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
TEMP_DIR="/tmp/${APP_NAME}_installer"
APP_DIR="${TEMP_DIR}/${APP_NAME}.app"
CONTENTS_DIR="${APP_DIR}/Contents"
MACOS_DIR="${CONTENTS_DIR}/MacOS"
RESOURCES_DIR="${CONTENTS_DIR}/Resources"

echo "📦 Creating MacCleanup installer..."

# Clean up any existing temp files
rm -rf "${TEMP_DIR}"
rm -f "${DMG_NAME}"

# Create directory structure
mkdir -p "${MACOS_DIR}"
mkdir -p "${RESOURCES_DIR}"

# Create the app launcher script
cat > "${MACOS_DIR}/MacCleanup" << 'SCRIPT'
#!/bin/bash
# Get the directory where the app is located
APP_DIR="$(cd "$(dirname "$0")/../../.." && pwd)"
cd "$APP_DIR"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    # First time setup
    osascript -e 'display notification "Setting up MacCleanup for first time..." with title "MacCleanup"'
    python3 -m venv venv
    source venv/bin/activate
    pip install -q flask watchdog schedule
else
    source venv/bin/activate
fi

# Open browser after delay
(sleep 2 && open "http://localhost:5050") &

# Run the app
python3 app.py
SCRIPT

chmod +x "${MACOS_DIR}/MacCleanup"

# Create Info.plist
cat > "${CONTENTS_DIR}/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleExecutable</key>
    <string>MacCleanup</string>
    <key>CFBundleIdentifier</key>
    <string>com.maccleanup.app</string>
    <key>CFBundleName</key>
    <string>MacCleanup</string>
    <key>CFBundleVersion</key>
    <string>1.0</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundlePackageType</key>
    <string>APPL</string>
    <key>LSMinimumSystemVersion</key>
    <string>10.13</string>
    <key>NSHighResolutionCapable</key>
    <true/>
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
</dict>
</plist>
PLIST

# Copy all project files to Resources
cp -r /Users/toddponskymd/CursorProjects/MacCleanup/* "${RESOURCES_DIR}/" 2>/dev/null
rm -rf "${RESOURCES_DIR}/.git" 2>/dev/null
rm -rf "${RESOURCES_DIR}/venv" 2>/dev/null

# Create README for installer
cat > "${TEMP_DIR}/README.txt" << 'README'
MacCleanup Installation
=======================

1. Drag MacCleanup.app to your Applications folder
2. Double-click MacCleanup.app to launch
3. The app will open in your browser at http://localhost:5050

First Time Setup:
- The app will automatically set up Python dependencies on first launch
- This may take a minute

Configuration:
- Edit ~/Applications/MacCleanup.app/Contents/Resources/config.py
- Update Dropbox path if needed
- Update external SSD path if you use a different drive name

For more information, visit:
https://github.com/tponsky/MacCleanup
README

# Create DMG
echo "Creating DMG file..."
hdiutil create -volname "${APP_NAME}" -srcfolder "${TEMP_DIR}" -ov -format UDZO "${DMG_NAME}"

if [ $? -eq 0 ]; then
    echo "✅ Installer created: ${DMG_NAME}"
    echo "   Share this file with others - they can double-click to install!"
    open -R "${DMG_NAME}"
else
    echo "❌ Failed to create DMG"
    exit 1
fi

# Clean up temp files
rm -rf "${TEMP_DIR}"

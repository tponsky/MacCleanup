#!/bin/bash
# Create DMG installer for MacCleanup
# Similar to MOV-to-MP4 converter packaging

APP_NAME="MacCleanup"
VERSION="1.0"
DMG_NAME="${APP_NAME}-${VERSION}.dmg"
TEMP_DIR="/tmp/${APP_NAME}_dmg"
APP_BUNDLE="${TEMP_DIR}/${APP_NAME}.app"
APP_CONTENTS="${APP_BUNDLE}/Contents"
APP_MACOS="${APP_CONTENTS}/MacOS"
APP_RESOURCES="${APP_CONTENTS}/Resources"

echo "📦 Creating MacCleanup DMG installer..."

# Clean up
rm -rf "${TEMP_DIR}"
rm -f "${DMG_NAME}"

# Create directory structure
mkdir -p "${APP_MACOS}"
mkdir -p "${APP_RESOURCES}"

# Create the main executable script
cat > "${APP_MACOS}/MacCleanup" << 'SCRIPT'
#!/bin/bash
# MacCleanup Launcher
APP_DIR="$(cd "$(dirname "$0")/../Resources" && pwd)"
cd "$APP_DIR"

# Check if first run
if [ ! -d "venv" ]; then
    osascript -e 'display notification "Setting up MacCleanup (first time only)..." with title "MacCleanup"'
    python3 -m venv venv
    source venv/bin/activate
    pip install -q --upgrade pip
    pip install -q -r requirements.txt
else
    source venv/bin/activate
fi

# Open browser after delay
(sleep 2 && open "http://localhost:5050") &

# Run the app
python3 app.py
SCRIPT

chmod +x "${APP_MACOS}/MacCleanup"

# Create Info.plist
cat > "${APP_CONTENTS}/Info.plist" << 'PLIST'
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
    <key>NSHumanReadableCopyright</key>
    <string>Copyright © 2025</string>
</dict>
</plist>
PLIST

# Copy all project files to Resources
echo "Copying files..."
cp -r /Users/toddponskymd/CursorProjects/MacCleanup/* "${APP_RESOURCES}/" 2>/dev/null
# Clean up files that shouldn't be in the app bundle
rm -rf "${APP_RESOURCES}/.git" 2>/dev/null
rm -rf "${APP_RESOURCES}/venv" 2>/dev/null
rm -f "${APP_RESOURCES}/*.dmg" 2>/dev/null
rm -f "${APP_RESOURCES}/*.zip" 2>/dev/null
rm -rf "${APP_RESOURCES}/dmg_source" 2>/dev/null

# Create README for the DMG
cat > "${TEMP_DIR}/README.txt" << 'README'
MacCleanup Installation
=======================

1. Drag "MacCleanup.app" to your Applications folder
2. Double-click "MacCleanup.app" to launch
3. Your browser will open automatically at http://localhost:5050

First Launch:
- The app will automatically install Python dependencies
- This takes 1-2 minutes the first time
- You'll see a notification when ready

Configuration:
Before first use, you should configure the app for your system:

1. Right-click "MacCleanup.app" → Show Package Contents
2. Navigate to Contents/Resources/
3. Open "config.py" in a text editor
4. Update the paths:
   - DROPBOX_ROOT: Your Dropbox folder path
   - SSD_ROOT: Your external drive path (if you use one)
   - Or set SSD_ROOT to None if you don't use external storage

For detailed instructions, see INSTALLATION.md in the Resources folder.

Need Help?
Visit: https://github.com/tponsky/MacCleanup

Enjoy your organized files! 🧹
README

# Code-sign the app
CERT_HASH="C1169D74637BC4423A446131BD9087422E2AEF66"
echo "Code-signing the app..."
codesign --deep --force --options runtime --timestamp \
  --sign "${CERT_HASH}" \
  "${APP_BUNDLE}"

if [ $? -eq 0 ]; then
    echo "✅ App code-signed successfully"
else
    echo "⚠️  Warning: Code signing failed, but continuing..."
fi

# Create DMG
echo "Creating DMG file..."
hdiutil create -volname "${APP_NAME}" -srcfolder "${TEMP_DIR}" -ov -format UDZO "${DMG_NAME}"

if [ $? -eq 0 ]; then
    echo ""
    echo "✅ DMG created successfully: ${DMG_NAME}"
    echo "   Location: $(pwd)/${DMG_NAME}"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Test the DMG by double-clicking it"
    echo "   2. Drag MacCleanup.app to Applications"
    echo "   3. Test that it works"
    echo "   4. Upload to GitHub Releases for sharing"
    echo ""
    
    # Open the DMG location in Finder
    open -R "${DMG_NAME}"
else
    echo "❌ Failed to create DMG"
    exit 1
fi

# Clean up
rm -rf "${TEMP_DIR}"

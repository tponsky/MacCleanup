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

# Create app icon with broom emoji
echo "Creating app icon..."
ICON_DIR="${APP_RESOURCES}/icon.iconset"
mkdir -p "${ICON_DIR}"

# Create icon using Python with PIL (broom emoji on colored background)
python3 - "${ICON_DIR}" << 'PYTHON_ICON' 2>/dev/null || true
import sys
import os

icon_dir = sys.argv[1] if len(sys.argv) > 1 else '/tmp/icon.iconset'

try:
    from PIL import Image, ImageDraw, ImageFont
    
    # Icon sizes needed for macOS
    sizes = [
        (1024, 1024, "icon_512x512@2x.png"),
        (512, 512, "icon_512x512.png"),
        (512, 512, "icon_256x256@2x.png"),
        (256, 256, "icon_256x256.png"),
        (256, 256, "icon_128x128@2x.png"),
        (128, 128, "icon_128x128.png"),
        (64, 64, "icon_32x32@2x.png"),
        (32, 32, "icon_32x32.png"),
        (32, 32, "icon_16x16@2x.png"),
        (16, 16, "icon_16x16.png"),
    ]
    
    os.makedirs(icon_dir, exist_ok=True)
    
    for width, height, filename in sizes:
        # Create image with gradient background (dark blue to purple)
        img = Image.new('RGB', (width, height), color=(26, 26, 46))
        draw = ImageDraw.Draw(img)
        
        # Draw gradient background
        for y in range(height):
            ratio = y / height
            r = int(26 + (233 - 26) * ratio)
            g = int(26 + (69 - 26) * ratio)
            b = int(46 + (96 - 46) * ratio)
            draw.line([(0, y), (width, y)], fill=(r, g, b))
        
        # Try to draw broom emoji (🧹)
        try:
            # Use system font that supports emoji
            font_size = int(width * 0.6)
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Apple Color Emoji.ttc", font_size)
            except:
                try:
                    font = ImageFont.truetype("/System/Library/Fonts/Supplemental/Apple Color Emoji.ttc", font_size)
                except:
                    font = ImageFont.load_default()
            
            # Draw broom emoji centered
            text = "🧹"
            bbox = draw.textbbox((0, 0), text, font=font)
            text_width = bbox[2] - bbox[0]
            text_height = bbox[3] - bbox[1]
            x = (width - text_width) // 2 - bbox[0]
            y = (height - text_height) // 2 - bbox[1]
            draw.text((x, y), text, font=font, fill=(255, 255, 255))
        except Exception as e:
            # Fallback: draw a simple circle with "MC" text
            center = (width // 2, height // 2)
            radius = min(width, height) // 3
            draw.ellipse([center[0]-radius, center[1]-radius, center[0]+radius, center[1]+radius], 
                        fill=(233, 69, 96), outline=(255, 255, 255), width=2)
            try:
                font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", int(width * 0.3))
            except:
                font = ImageFont.load_default()
            text = "MC"
            bbox = draw.textbbox((0, 0), text, font=font)
            text_width = bbox[2] - bbox[0]
            text_height = bbox[3] - bbox[1]
            x = (width - text_width) // 2 - bbox[0]
            y = (height - text_height) // 2 - bbox[1]
            draw.text((x, y), text, font=font, fill=(255, 255, 255))
        
        # Save icon
        output_path = os.path.join(icon_dir, filename)
        img.save(output_path, 'PNG')
        print(f"Created: {filename}")
    
    print("✅ Icons created successfully")
except ImportError:
    print("⚠️  PIL not available, using system icon fallback")
    # Fallback to system icon
    import subprocess
    if os.path.exists("/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns"):
        subprocess.run(['sips', '-s', 'format', 'png', '-z', '512', '512',
                       '/System/Library/CoreServices/CoreTypes.bundle/Contents/Resources/GenericApplicationIcon.icns',
                       '--out', os.path.join(icon_dir, 'icon_512x512.png')], 
                      capture_output=True, check=False)
except Exception as e:
    print(f"⚠️  Icon creation error: {e}")
PYTHON_ICON

# Convert to .icns if iconutil is available
if command -v iconutil &> /dev/null && [ -d "${ICON_DIR}" ] && [ "$(ls -A ${ICON_DIR} 2>/dev/null)" ]; then
    iconutil -c icns "${ICON_DIR}" -o "${APP_RESOURCES}/AppIcon.icns" 2>/dev/null || echo "⚠️  Icon creation skipped"
    rm -rf "${ICON_DIR}"
    echo "✅ App icon created"
else
    echo "⚠️  Icon creation skipped - using system default"
fi

# Create Info.plist with icon reference
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
    <key>CFBundleIconFile</key>
    <string>AppIcon</string>
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
# IMPORTANT: Remove user_config.json so setup wizard shows on first run
echo "Removing user_config.json to ensure setup wizard shows on first run..."
if [ -f "${APP_RESOURCES}/user_config.json" ]; then
    rm -f "${APP_RESOURCES}/user_config.json"
    echo "✅ Removed user_config.json"
else
    echo "✅ user_config.json already removed (good!)"
fi

# Create professional DMG layout
echo "Setting up professional DMG layout..."

# Create Applications folder link
ln -s /Applications "${TEMP_DIR}/Applications"

# Create a visible instruction graphic file (more reliable than background)
python3 << 'INSTRUCTIONS_PY' 2>/dev/null || true
try:
    from PIL import Image, ImageDraw, ImageFont
    import os
    
    # Create instruction image (600x400)
    img = Image.new('RGB', (600, 400), color=(26, 26, 46))
    draw = ImageDraw.Draw(img)
    
    # Gradient background
    for y in range(400):
        ratio = y / 400
        r = int(26 + (40 - 26) * ratio)
        g = int(26 + (33 - 26) * ratio)
        b = int(46 + (62 - 46) * ratio)
        draw.line([(0, y), (600, y)], fill=(r, g, b))
    
    try:
        font_large = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 32)
        font_medium = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 18)
        font_small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14)
    except:
        font_large = ImageFont.load_default()
        font_medium = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    # Title
    draw.text((300, 30), "MacCleanup", fill=(255, 255, 255), anchor="mm", font=font_large)
    
    # Arrow (simple line with arrowhead)
    arrow_y = 100
    draw.line([(100, arrow_y), (500, arrow_y)], fill=(233, 69, 96), width=4)
    # Arrowhead
    draw.polygon([(500, arrow_y), (480, arrow_y-10), (480, arrow_y+10)], fill=(233, 69, 96))
    
    # Instructions
    draw.text((300, 130), "Drag MacCleanup.app → Applications", fill=(233, 69, 96), anchor="mm", font=font_medium)
    
    y_pos = 180
    draw.text((300, y_pos), "STEP 1: Drag to Applications (Do this first!)", fill=(255, 255, 255), anchor="mm", font=font_small)
    y_pos += 30
    draw.text((300, y_pos), "STEP 2: Open from Applications folder", fill=(160, 160, 176), anchor="mm", font=font_small)
    y_pos += 30
    draw.text((300, y_pos), "STEP 3: Complete setup wizard in browser", fill=(0, 217, 165), anchor="mm", font=font_small)
    y_pos += 30
    draw.text((300, y_pos), "(Auto-detects Dropbox & external drives)", fill=(160, 160, 176), anchor="mm", font=ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 12) if 'Helvetica' in str(font_small) else font_small)
    
    # Save as visible file
    img.save('INSTALL_INSTRUCTIONS.png')
    print("✅ Instruction graphic created")
except Exception as e:
    print(f"⚠️  Could not create instruction graphic: {e}")
INSTRUCTIONS_PY

# Move instruction file if created
if [ -f "INSTALL_INSTRUCTIONS.png" ]; then
    mv "INSTALL_INSTRUCTIONS.png" "${TEMP_DIR}/INSTALL_INSTRUCTIONS.png"
    echo "✅ Instruction graphic added to DMG"
fi

# Create simple text README as backup
cat > "${TEMP_DIR}/README.txt" << 'README'
═══════════════════════════════════════════════════════════════
  MacCleanup - Installation Instructions
═══════════════════════════════════════════════════════════════

STEP 1: Drag MacCleanup.app to the Applications folder
        (Drag the app icon to the Applications folder icon)

STEP 2: Open MacCleanup from Applications
        - Go to Applications folder
        - Double-click MacCleanup.app
        - Your browser will open automatically

STEP 3: Complete Setup (First Time Only)
        - The setup wizard will appear in your browser
        - It will auto-detect your Dropbox and external drives
        - Fill out the form and click "Save Configuration"
        - You're ready to use MacCleanup!

═══════════════════════════════════════════════════════════════
README

# Create professional background image with arrow graphic
BG_IMAGE="${TEMP_DIR}/.background.png"
python3 << 'PYTHON' 2>/dev/null || true
try:
    from PIL import Image, ImageDraw, ImageFont
    import os
    import math
    
    # Create background image (800x500 for better layout)
    img = Image.new('RGB', (800, 500), color=(26, 26, 46))  # Dark blue background
    draw = ImageDraw.Draw(img)
    
    # Draw gradient background
    for y in range(500):
        ratio = y / 500
        r = int(26 + (40 - 26) * ratio)
        g = int(26 + (33 - 26) * ratio)
        b = int(46 + (62 - 46) * ratio)
        draw.line([(0, y), (800, y)], fill=(r, g, b))
    
    # Draw title
    try:
        font_large = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 42)
        font_medium = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 20)
        font_small = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 16)
    except:
        font_large = ImageFont.load_default()
        font_medium = ImageFont.load_default()
        font_small = ImageFont.load_default()
    
    # Title at top
    draw.text((400, 40), "MacCleanup", fill=(255, 255, 255), anchor="mm", font=font_large)
    
    # App icon position (left side)
    app_x, app_y = 150, 200
    # Applications folder position (right side)
    apps_x, apps_y = 600, 200
    
    # Draw arrow from app to Applications
    arrow_start = (app_x + 100, app_y + 50)  # Right side of app icon
    arrow_end = (apps_x - 20, apps_y + 50)   # Left side of Applications folder
    arrow_mid_x = (arrow_start[0] + arrow_end[0]) // 2
    
    # Draw arrow line
    draw.line([arrow_start, arrow_end], fill=(233, 69, 96), width=6)
    
    # Draw arrowhead (triangle)
    arrow_size = 20
    arrow_points = [
        arrow_end,
        (arrow_end[0] - arrow_size, arrow_end[1] - arrow_size // 2),
        (arrow_end[0] - arrow_size, arrow_end[1] + arrow_size // 2),
    ]
    draw.polygon(arrow_points, fill=(233, 69, 96))
    
    # Draw main instruction above arrow (larger, more prominent)
    instruction_y = arrow_start[1] - 50
    draw.text((400, instruction_y), "Drag MacCleanup.app → Applications folder", 
              fill=(233, 69, 96), anchor="mm", font=font_medium)
    
    # Draw step-by-step instructions below
    steps_y = 350
    step_font = ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 18) if 'Helvetica' in str(font_medium) else font_small
    
    # Step 1 - Left side
    draw.text((150, steps_y), "STEP 1:", fill=(255, 255, 255), anchor="mm", font=step_font)
    draw.text((150, steps_y + 25), "Drag to Applications", fill=(160, 160, 176), anchor="mm", font=font_small)
    draw.text((150, steps_y + 45), "(Do this first!)", fill=(233, 69, 96), anchor="mm", font=font_small)
    
    # Step 2 - Right side  
    draw.text((600, steps_y), "STEP 2:", fill=(255, 255, 255), anchor="mm", font=step_font)
    draw.text((600, steps_y + 25), "Open from Applications", fill=(160, 160, 176), anchor="mm", font=font_small)
    draw.text((600, steps_y + 45), "(Then double-click)", fill=(160, 160, 176), anchor="mm", font=font_small)
    
    # Step 3 - Center bottom
    draw.text((400, steps_y + 80), "STEP 3: Complete setup wizard in your browser", 
              fill=(0, 217, 165), anchor="mm", font=font_small)
    draw.text((400, steps_y + 100), "(Auto-detects Dropbox & external drives)", 
              fill=(160, 160, 176), anchor="mm", font=ImageFont.truetype("/System/Library/Fonts/Helvetica.ttc", 14) if 'Helvetica' in str(font_medium) else font_small)
    
    # Save background
    img.save('.background.png')
    print("✅ Background with arrow created")
except ImportError:
    print("⚠️  PIL not available, creating simple background")
    # Fallback: create simple text file
    pass
except Exception as e:
    print(f"⚠️  Background creation error: {e}")
PYTHON

# Move background if created
if [ -f ".background.png" ]; then
    mv .background.png "${BG_IMAGE}"
fi

# Create DMG with proper layout
echo "Creating DMG with professional layout..."

# Code-sign the app (same as MOV-to-MP4 converter)
CERT_HASH="C1169D74637BC4423A446131BD9087422E2AEF66"
DEV_ID="Developer ID Application: Bobbin LLC (8YY98N4P3K)"
TEAM_ID="8YY98N4P3K"
APPLE_ID="tponsky@gmail.com"
NOTARY_PASSWORD="mkzn-hjun-giux-truf"

echo "Code-signing the app..."
# Remove extended attributes before signing
xattr -cr "${APP_BUNDLE}"
# Sign the app with hardened runtime (same as MOV-to-MP4)
codesign --force --options runtime --timestamp \
  --sign "${CERT_HASH}" \
  "${APP_BUNDLE}"

if [ $? -eq 0 ]; then
    echo "✅ App code-signed successfully"
else
    echo "⚠️  Warning: Code signing failed, but continuing..."
fi

# Create DMG (we'll customize it after creation)
echo "Creating DMG file..."
hdiutil create -volname "${APP_NAME}" -srcfolder "${TEMP_DIR}" -ov -format UDZO "${DMG_NAME}"

if [ $? -ne 0 ]; then
    echo "❌ Failed to create DMG"
    exit 1
fi

# Mount the DMG to customize it
echo "Customizing DMG layout..."
DMG_MOUNT="/Volumes/${APP_NAME}"
DMG_DEVICE=$(hdiutil attach -readwrite -noverify -noautoopen "${DMG_NAME}" | egrep '^/dev/' | sed 1q | awk '{print $1}')

# Wait for mount
sleep 2

# Set up the DMG window appearance
if [ -d "${DMG_MOUNT}" ]; then
    echo "Configuring DMG window layout..."
    
    # Create .background folder and copy image (this is the reliable method!)
    if [ -f "${BG_IMAGE}" ]; then
        mkdir -p "${DMG_MOUNT}/.background"
        cp "${BG_IMAGE}" "${DMG_MOUNT}/.background/background.png"
        echo "✅ Background image copied to .background folder"
    else
        echo "⚠️  Background image not found at ${BG_IMAGE}"
    fi
    
    # Wait a moment for Finder to recognize the mount
    sleep 3
    
    # Set up DMG layout using AppleScript
    osascript << EOF
    tell application "Finder"
        -- Wait for disk to be available
        repeat while not (disk "${APP_NAME}" exists)
            delay 0.5
        end repeat
        
        tell disk "${APP_NAME}"
            -- Open the window first
            open
            delay 2
            
            -- Get the window
            set win to container window
            
            -- Configure window appearance (matching 800x500 background)
            set current view of win to icon view
            set toolbar visible of win to false
            set statusbar visible of win to false
            set the bounds of win to {400, 100, 1200, 600}
            
            -- Get icon view options
            set opts to icon view options of win
            set arrangement of opts to not arranged
            set icon size of opts to 96
            
            -- Set background image from .background folder (reliable method!)
            try
                set bgFolder to folder ".background" of disk "${APP_NAME}"
                set bgFile to file "background.png" of bgFolder
                set background picture of opts to bgFile
                log "✅ Background image set from .background folder"
            on error errMsg
                log "⚠️  Background error: " & errMsg
            end try
            
            -- Position icons (matching background arrow)
            set position of item "${APP_NAME}.app" of win to {120, 180}
            set position of item "Applications" of win to {560, 180}
            
            -- Hide instruction files (we want clean look like Google Drive)
            if (exists item "INSTALL_INSTRUCTIONS.png" of disk "${APP_NAME}") then
                set position of item "INSTALL_INSTRUCTIONS.png" of win to {1000, 1000}
            end if
            if (exists item "README.txt" of disk "${APP_NAME}") then
                set position of item "README.txt" of win to {1000, 1000}
            end if
            
            -- Force save the view settings
            update without registering applications
            delay 1
            
            -- Close and reopen to ensure settings stick
            close
            delay 1
            open
            delay 2
            
            -- Verify background is set
            try
                set bgSet to background picture of opts
                if bgSet is not missing value then
                    log "✅ Background verified as set"
                end if
            on error
                log "⚠️  Could not verify background"
            end try
        end tell
    end tell
EOF
    
    # Hide .background folder AFTER AppleScript sets it
    if [ -d "${DMG_MOUNT}/.background" ]; then
        # Use SetFile if available, otherwise chflags
        if command -v SetFile &> /dev/null; then
            SetFile -a V "${DMG_MOUNT}/.background" 2>/dev/null || true
        else
            chflags hidden "${DMG_MOUNT}/.background" 2>/dev/null || true
        fi
        echo "✅ .background folder hidden"
    fi
    
    # Eject the DMG
    echo "Ejecting DMG..."
    hdiutil detach "${DMG_DEVICE}" -force
    sleep 2
fi

# Sign the DMG (same as MOV-to-MP4)
echo "Signing DMG..."
codesign --force --timestamp --sign "${CERT_HASH}" "${DMG_NAME}"

if [ $? -eq 0 ]; then
    echo "✅ DMG signed successfully"
else
    echo "⚠️  Warning: DMG signing failed, but continuing..."
fi

# Notarize the DMG (this is what makes it trusted by macOS!)
echo "Notarizing DMG (this may take a few minutes)..."
xcrun notarytool submit "${DMG_NAME}" \
    --apple-id "${APPLE_ID}" \
    --password "${NOTARY_PASSWORD}" \
    --team-id "${TEAM_ID}" \
    --wait

if [ $? -eq 0 ]; then
    echo "✅ DMG notarized successfully"
    
    # Staple the notarization ticket to the DMG
    echo "Stapling notarization ticket..."
    xcrun stapler staple "${DMG_NAME}"
    
    if [ $? -eq 0 ]; then
        echo "✅ Notarization ticket stapled"
    else
        echo "⚠️  Warning: Stapling failed, but DMG is still notarized"
    fi
else
    echo "⚠️  Warning: Notarization failed, but DMG is still signed"
fi

if [ -f "${DMG_NAME}" ]; then
    echo ""
    echo "✅ DMG created successfully: ${DMG_NAME}"
    echo "   Location: $(pwd)/${DMG_NAME}"
    echo ""
    echo "📋 Next steps:"
    echo "   1. Test the DMG by double-clicking it"
    echo "   2. Drag MacCleanup.app to Applications"
    echo "   3. Test that it works (should open without warnings!)"
    echo "   4. Upload to server for sharing"
    echo ""
    
    # Open the DMG location in Finder
    open -R "${DMG_NAME}"
else
    echo "❌ DMG file not found after creation"
    exit 1
fi

# Clean up
rm -rf "${TEMP_DIR}"

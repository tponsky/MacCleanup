# MacCleanup User Experience Guide

## Answers to Your Questions

### 1. How and Where Does It Ask Custom Questions?

**Answer:** The app uses a **web-based setup wizard** that appears automatically when users first launch the app.

**How it works:**
- When the app launches, it checks if `user_config.json` exists
- If it doesn't exist (first time), the app shows a beautiful setup page at `http://localhost:5050`
- The setup page automatically detects:
  - Dropbox folder location
  - External drives connected
- Users fill out a simple form:
  - Dropbox path (auto-filled if detected, or can enter manually)
  - External drive selection (dropdown of detected drives)
  - Checkbox: "Drive is always connected"
- Click "Save Configuration" → redirects to main dashboard
- After first setup, the app goes directly to the main dashboard

**Location:** The setup wizard appears in the user's browser at `http://localhost:5050` when they first launch the app.

---

### 2. What Website Does It Open? (localhost:5050)

**Answer:** Yes, it opens `http://localhost:5050` on their Mac, and this is **correct and expected behavior**.

**Why localhost is correct:**
- The app runs **locally on their Mac** (not on a server)
- `localhost:5050` means the web interface runs on their own computer
- This is the same approach as many professional Mac apps (like Docker Desktop, etc.)
- **Benefits:**
  - ✅ Privacy: All file operations happen locally
  - ✅ Speed: No internet required after setup
  - ✅ Security: Files never leave their Mac
  - ✅ Works offline

**What users see:**
- When they double-click `MacCleanup.app`, their browser automatically opens to `http://localhost:5050`
- The web interface is beautiful and works just like a website
- But everything runs locally - no server needed!

---

### 3. App Icon

**Answer:** ✅ **Added!** The app now has an icon that appears in:
- Applications folder
- Dock (when running)
- Finder
- Spotlight search

**How it works:**
- Icon is created automatically during DMG build
- Uses system tools to generate proper `.icns` format
- You can replace it with a custom icon later by:
  1. Creating a custom icon file
  2. Placing it in the app's Resources folder as `AppIcon.icns`
  3. Rebuilding the DMG

---

### 4. Professional DMG UI with Drag-to-Install

**Answer:** ✅ **Implemented!** The DMG now has a professional interface like other Mac apps.

**Features:**
- ✅ **Applications folder link** - Users can drag the app directly to it
- ✅ **Professional layout** - Icons positioned properly
- ✅ **Background image** - Clean, branded appearance (optional)
- ✅ **Window sizing** - Proper dimensions for easy installation
- ✅ **Icon positioning** - App icon on left, Applications folder on right

**What users see when they open the DMG:**
```
┌─────────────────────────────────────┐
│  MacCleanup                        │
│  Drag to Applications folder       │
│                                     │
│  [MacCleanup.app]  →  [Applications]│
│                                     │
└─────────────────────────────────────┘
```

**User experience:**
1. User downloads DMG
2. Double-clicks DMG → it opens
3. Sees professional layout with app icon and Applications folder
4. Drags `MacCleanup.app` to `Applications` folder
5. Done! Installation complete

---

## Complete User Flow

### First Time User Experience:

1. **Download DMG** from website
2. **Open DMG** → See professional drag-to-install interface
3. **Drag app to Applications** folder
4. **Double-click app** in Applications
5. **Browser opens** automatically to `http://localhost:5050`
6. **Setup wizard appears** (if first time):
   - Auto-detects Dropbox
   - Auto-detects external drives
   - User fills form and clicks "Save"
7. **Main dashboard appears** - ready to use!

### Subsequent Uses:

1. **Double-click app** in Applications
2. **Browser opens** to `http://localhost:5050`
3. **Main dashboard** appears immediately (no setup needed)

---

## Technical Details

### Setup Wizard Location
- **File:** `app.py` - `SETUP_TEMPLATE` constant (lines 874-1186)
- **Route:** `/` - checks for `user_config.json`
- **API Endpoints:**
  - `/api/setup/detect` - Detects Dropbox and drives
  - `/api/setup/save` - Saves user configuration

### Localhost Behavior
- **Port:** 5050 (configurable in `app.py`)
- **Host:** 127.0.0.1 (localhost only - secure)
- **Auto-open:** Browser opens automatically via `open "http://localhost:5050"`

### Icon Implementation
- **Location:** `Contents/Resources/AppIcon.icns`
- **Info.plist:** References `CFBundleIconFile: AppIcon`
- **Formats:** Automatically generates all required sizes

### DMG Layout
- **Script:** `create_dmg.sh` - lines 143-220
- **Tools:** Uses `hdiutil` and AppleScript for layout
- **Background:** Optional PNG image (can be customized)

---

## Summary

✅ **Custom questions:** Web-based setup wizard at localhost:5050 (first launch only)  
✅ **Website:** localhost:5050 (correct - runs locally on their Mac)  
✅ **App icon:** Created automatically, appears in Applications/Dock  
✅ **Professional DMG:** Drag-to-install interface with Applications folder link  

Everything is now set up for a professional user experience! 🎉

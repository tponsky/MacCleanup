# How MacCleanup Customizes for Each User

## Overview

MacCleanup automatically customizes itself for each user on their Mac. Each user runs the setup wizard once, and the app saves their configuration. This means:

- ✅ **Each user has their own configuration** - stored on their Mac
- ✅ **Each user's Dropbox/iCloud paths** - detected or configured by them
- ✅ **Each user's external drives** - detected and configured by them
- ✅ **No server, no cloud storage of config** - everything stays on their Mac

---

## How It Works (Step by Step)

### Step 1: First Launch - Setup Wizard

When a user first launches MacCleanup:

1. **User double-clicks `MacCleanup.app`**
2. **App checks if `user_config.json` exists**
3. **If not found, the app suggests running the setup wizard**

### Step 2: User Runs Setup Wizard

User runs the setup wizard:

```bash
cd /Applications/MacCleanup.app/Contents/Resources
python3 setup_wizard.py
```

The wizard:

1. **Detects Dropbox automatically:**
   - Checks common locations: `~/Dropbox`, `~/Dropbox (Personal)`, etc.
   - If found, asks: "Use this Dropbox folder? (Y/n)"
   - If not found, asks user to:
     - Enter Dropbox path manually
     - Use iCloud Drive instead
     - Skip cloud storage

2. **Detects external drives:**
   - Scans `/Volumes/` for drives
   - If found, asks: "Use external drive for large files? (Y/n)"
   - If multiple drives, asks user to select one
   - If none, sets to `None`

3. **Saves configuration to `user_config.json`:**

```json
{
  "dropbox_root": "/Users/john/Dropbox",
  "ssd_root": "/Volumes/My External Drive"
}
```

Or if they use iCloud:

```json
{
  "dropbox_root": "/Users/john/Library/Mobile Documents/com~apple~CloudDocs",
  "ssd_root": null
}
```

Or if they skip cloud storage:

```json
{
  "dropbox_root": null,
  "ssd_root": null
}
```

### Step 3: App Uses User's Configuration

Every time the app runs, it:

1. **Reads `user_config.json`** (stored in the app bundle)
2. **Uses those paths** for organizing files
3. **Creates folders based on user's paths:**

For example, if user has Dropbox at `/Users/john/Dropbox`:
- Presentations → `/Users/john/Dropbox/Work/Presentations/`
- PDFs → `/Users/john/Dropbox/Reference/PDFs/`
- Screenshots → `/Users/john/Dropbox/Media/Screenshots/`
- Archive → `/Users/john/Dropbox/Archive/`

---

## Example: Different Users

### User 1: Uses Dropbox

**Setup:**
```json
{
  "dropbox_root": "/Users/john/Dropbox",
  "ssd_root": "/Volumes/My External Drive"
}
```

**Files get organized to:**
- `/Users/john/Dropbox/Work/Presentations/`
- `/Users/john/Dropbox/Media/Screenshots/`
- `/Volumes/My External Drive/Videos/To-Review/`

### User 2: Uses iCloud Drive

**Setup:**
```json
{
  "dropbox_root": "/Users/jane/Library/Mobile Documents/com~apple~CloudDocs",
  "ssd_root": null
}
```

**Files get organized to:**
- `/Users/jane/Library/Mobile Documents/com~apple~CloudDocs/Work/Presentations/`
- `/Users/jane/Library/Mobile Documents/com~apple~CloudDocs/Media/Screenshots/`
- Videos stay on laptop (no external drive)

### User 3: No Cloud Storage

**Setup:**
```json
{
  "dropbox_root": null,
  "ssd_root": null
}
```

**Files get organized to:**
- Only local folders (if configured)
- Or app can warn/ask user to configure cloud storage

---

## Key Points

### ✅ Each User's Configuration is Separate

- **Your configuration:** Stored on your Mac in your app bundle
- **Other users' configurations:** Stored on their Macs in their app bundles
- **No shared configuration:** Each user has their own `user_config.json`

### ✅ Automatic Detection

The setup wizard tries to detect:
- Dropbox folder automatically (checks common locations)
- External drives automatically (scans `/Volumes/`)
- Makes setup easier for users

### ✅ User Choice

Users can:
- Use Dropbox (if detected or manually entered)
- Use iCloud Drive instead
- Skip cloud storage
- Configure external drives
- Change configuration later (edit `user_config.json`)

### ✅ Configuration Location

`user_config.json` is stored:
- **Location:** `/Applications/MacCleanup.app/Contents/Resources/user_config.json`
- **On their Mac:** Not on your server, not shared
- **Private:** Only affects their Mac

---

## How Users Can Change Configuration

### Option 1: Edit user_config.json (Manual)

1. Right-click `MacCleanup.app` → Show Package Contents
2. Navigate to: `Contents/Resources/`
3. Open `user_config.json` in a text editor
4. Update paths
5. Save

### Option 2: Re-run Setup Wizard

1. Right-click `MacCleanup.app` → Show Package Contents
2. Navigate to: `Contents/Resources/`
3. Run: `python3 setup_wizard.py`
4. Follow prompts again

---

## Technical Details

### Configuration Flow

```
User launches app
    ↓
App checks for user_config.json
    ↓
If not found → Suggest running setup_wizard.py
    ↓
User runs setup_wizard.py
    ↓
Wizard detects Dropbox/drives
    ↓
User confirms/enters paths
    ↓
Wizard saves to user_config.json
    ↓
App reads user_config.json
    ↓
App uses those paths for file organization
```

### Code Flow

1. **config.py** reads `user_config.json`:
```python
USER_CONFIG_FILE = Path(__file__).parent / "user_config.json"
user_config = {}
if USER_CONFIG_FILE.exists():
    with open(USER_CONFIG_FILE, 'r') as f:
        user_config = json.load(f)

# Use user's paths
if user_config.get('dropbox_root'):
    DROPBOX_ROOT = Path(user_config['dropbox_root'])
```

2. **cleanup_engine.py** uses those paths:
```python
# Uses DROPBOX_ROOT from config.py
# Which comes from user_config.json
```

3. **App organizes files** to user's paths:
```python
# Files go to user's Dropbox, not yours
destination = config.DROPBOX_FOLDERS["presentations"]
# Which is based on user's dropbox_root
```

---

## Summary

✅ **Each user configures the app on their Mac**  
✅ **Configuration stored locally on their Mac**  
✅ **No server, no cloud storage of config**  
✅ **Automatic detection makes setup easy**  
✅ **Users can change configuration anytime**  
✅ **Each user's files go to their own Dropbox/iCloud**  

**The app is fully customized for each user, and each user's configuration is completely separate!**

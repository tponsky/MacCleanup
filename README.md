# MacCleanup 🧹

A beautiful web-based file cleanup tool for your Mac. Automatically organizes, categorizes, and cleans up files across Desktop, Downloads, and Documents.

## Features

- **Visual Dashboard** - See file statistics at a glance
- **Smart Categorization** - Automatically identifies file types
- **One-Click Cleanup** - Delete junk, move files to proper locations
- **Dropbox Integration** - Organizes files into your Dropbox structure
- **SSD Support** - Moves large videos to your external SSD
- **Scheduled Runs** - Automatically cleans up weekly
- **Duplicate Detection** - Finds files with (1), (2), copy, etc.

## Quick Start

### Option 1: Use the App (Recommended)
1. Find **MacCleanup.app** in `/Users/toddponskymd/Applications/`
2. Drag it to your Dock for easy access
3. Click to launch - browser opens automatically

### Option 2: Run from Terminal
```bash
cd ~/CursorProjects/MacCleanup
./start.sh
```

### Option 3: Run Cleanup Without GUI
```bash
cd ~/CursorProjects/MacCleanup
source venv/bin/activate
python3 auto_cleanup.py
```

## Setting Up Automatic Weekly Cleanup

Run this once to schedule automatic cleanup every Monday at 9 AM:

```bash
cd ~/CursorProjects/MacCleanup
./setup_scheduler.sh
```

To disable automatic cleanup:
```bash
launchctl unload ~/Library/LaunchAgents/com.maccleanup.auto.plist
```

## What Gets Cleaned

### Automatically Deleted
- Office temp files (`~$*.pptx`, `~$*.docx`)
- `.DS_Store` files
- Temp files (`*.tmp`)
- Old installers (`.dmg`, `.pkg` in Downloads)

### Automatically Moved to Dropbox
- Presentations → `Dropbox/Work/Presentations/`
- PDFs → `Dropbox/Reference/PDFs/`
- Screenshots → `Dropbox/Media/Screenshots/`
- Old files → `Dropbox/Archive/`

### Automatically Moved to SSD (if connected)
- Video files → `SSD/Videos/To-Review/`

### Flagged for Review
- Files larger than 100MB
- Potential duplicates
- Files older than 90 days

## Folder Structure

Your files are organized into:

```
~/GlobalCastMD Dropbox/Todd Ponsky/
├── Work/
│   ├── CCHMC/
│   ├── GlobalCastMD/
│   └── Presentations/
├── Projects/
├── Reference/PDFs/
├── Media/
│   ├── Videos/
│   └── Screenshots/
└── Archive/

/Volumes/Extreme SSD/
├── Videos/
│   ├── AI-Demos/
│   ├── Presentations/
│   ├── Personal/
│   ├── Work-Projects/
│   └── To-Review/
└── Final-Cut-Projects/
```

## Customization

Edit `config.py` to customize:
- Watched directories
- File categories
- Age thresholds
- Size thresholds
- Destination folders

## Troubleshooting

**App won't open?**
- Right-click → Open (first time only, bypasses Gatekeeper)

**Dropbox not detected?**
- Make sure Dropbox is running and synced

**SSD not detected?**
- Connect your "Extreme SSD" drive

**Need to see logs?**
```bash
cat /tmp/maccleanup.log
cat /tmp/maccleanup.error.log
```

---

Made with ❤️ for Todd's MacBook

# MacCleanup 🧹

A beautiful web-based file cleanup tool for your Mac. Automatically organizes, categorizes, and cleans up files across Desktop, Downloads, and Documents.

![MacCleanup Dashboard](https://img.shields.io/badge/status-active-success) ![Python](https://img.shields.io/badge/python-3.8+-blue) ![License](https://img.shields.io/badge/license-MIT-green)

## 🚀 Quick Download & Install

### Option 1: DMG Installer (Recommended - Easiest!)

1. **[Download MacCleanup-1.0.dmg](https://github.com/tponsky/MacCleanup/releases/latest/download/MacCleanup-1.0.dmg)**
2. Double-click the DMG file
3. Drag `MacCleanup.app` to your Applications folder
4. Double-click `MacCleanup.app` to launch
5. Your browser opens automatically at `http://localhost:5050`

**First Launch:**
- The app automatically installs Python dependencies (takes 1-2 minutes)
- You'll see a notification when ready
- **Configure your paths** (see Configuration below)

---

### Option 2: From Source

1. **Clone the repository:**
   ```bash
   git clone https://github.com/tponsky/MacCleanup.git
   cd MacCleanup
   ```

2. **Set up Python environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Run setup wizard (recommended for first time):**
   ```bash
   python3 setup_wizard.py
   ```
   This helps you configure Dropbox/iCloud and external drive paths.

4. **Or launch directly:**
   ```bash
   ./start.sh
   ```

---

## ⚙️ Configuration (Important!)

**MacCleanup needs to know where your files are stored!**

### Quick Configuration:

Run the setup wizard:
```bash
python3 setup_wizard.py
```

### Manual Configuration:

1. Open `config.py` in a text editor
2. Update these paths:
   - `DROPBOX_ROOT`: Your Dropbox folder path
   - `SSD_ROOT`: Your external drive path (or set to `None` if you don't use one)

**Example configurations:**

```python
# Using Dropbox
DROPBOX_ROOT = HOME / "Dropbox" / "Your Name"

# Using iCloud Drive
DROPBOX_ROOT = HOME / "Library" / "Mobile Documents" / "com~apple~CloudDocs"

# No cloud storage
DROPBOX_ROOT = None

# External drive
SSD_ROOT = Path("/Volumes/My External Drive")

# No external drive
SSD_ROOT = None
```

**For DMG users:** Right-click `MacCleanup.app` → Show Package Contents → Contents/Resources/config.py

---

## ✨ Features

- **Visual Dashboard** - See file statistics at a glance
- **Smart Categorization** - Automatically identifies file types
- **One-Click Cleanup** - Delete junk, move files to proper locations
- **Selectable Actions** - Checkboxes to choose what to clean
- **Dropbox/iCloud Integration** - Organizes files into your cloud storage
- **SSD Support** - Moves large videos to your external SSD
- **Version Detection** - Identifies latest versions of duplicate files
- **Scheduled Runs** - Automatically cleans up weekly
- **Archive Old Files** - Moves files older than 30-90 days to archive

---

## 📖 How It Works

### What Gets Cleaned

**Automatically Deleted:**
- Office temp files (`~$*.pptx`)
- `.DS_Store` files
- Installer files (`.dmg`, `.pkg`)

**Automatically Moved:**
- Presentations → `Dropbox/Work/Presentations/`
- PDFs → `Dropbox/Reference/PDFs/`
- Screenshots → `Dropbox/Media/Screenshots/`
- Videos → External SSD (if configured)

**Archived (Old Files):**
- Screenshots >30 days → `Dropbox/Media/Screenshots/Archive/`
- Files >90 days → `Dropbox/Archive/`

---

## 🎯 Usage

1. **Launch the app** (click `MacCleanup.app` or run `./start.sh`)
2. **Open your browser** at `http://localhost:5050`
3. **Click "Preview Cleanup"** to see suggested actions
4. **Select/deselect** actions using checkboxes
5. **Click "Run Cleanup"** to execute selected actions

---

## ⏰ Automatic Cleanup

Set up weekly automatic cleanup:

```bash
cd ~/CursorProjects/MacCleanup
./setup_scheduler.sh
```

This runs cleanup every Monday at 9:00 AM automatically.

To disable:
```bash
launchctl unload ~/Library/LaunchAgents/com.maccleanup.auto.plist
```

---

## 📁 Folder Structure

Files are organized into:

```
Dropbox/
├── Work/
│   ├── Presentations/
│   └── Documents/
├── Reference/PDFs/
├── Media/
│   ├── Videos/
│   └── Screenshots/
└── Archive/

External SSD/
├── Videos/
│   ├── AI-Demos/
│   ├── Presentations/
│   └── To-Review/
└── Final-Cut-Projects/
```

---

## 🛠️ Troubleshooting

### Port 5050 already in use
- Close other apps using port 5050
- Or edit `app.py` and change `port=5050` to a different number

### Dropbox not found
- Make sure Dropbox is installed and running
- Update `DROPBOX_ROOT` in `config.py` to match your Dropbox path
- Or use the setup wizard: `python3 setup_wizard.py`

### Permission denied
```bash
chmod +x start.sh setup_scheduler.sh auto_cleanup.py
```

### App won't open (Gatekeeper)
- Right-click `MacCleanup.app` → Open → Click "Open" in the dialog

---

## 📚 Documentation

- **[INSTALLATION.md](INSTALLATION.md)** - Detailed installation guide
- **[SHARING.md](SHARING.md)** - How to share with others
- **[DEPLOYMENT.md](DEPLOYMENT.md)** - Deployment options
- **[ARCHIVING_EXPLAINED.md](ARCHIVING_EXPLAINED.md)** - How archiving works

---

## 🤝 Sharing with Others

**Easiest way:** Share the GitHub link: https://github.com/tponsky/MacCleanup

Or share the DMG installer from [Releases](https://github.com/tponsky/MacCleanup/releases).

See [SHARING.md](SHARING.md) for more details.

---

## 📝 Requirements

- macOS 10.13 or later
- Python 3.8+ (usually pre-installed on Mac)
- Dropbox (optional, but recommended)
- External SSD (optional, for large video files)

---

## 📄 License

MIT License - feel free to use and modify!

---

**Repository:** https://github.com/tponsky/MacCleanup

**Made with ❤️ for organized file management**

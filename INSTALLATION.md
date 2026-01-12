# MacCleanup Installation Guide

## 📥 Download & Install (Easiest Method)

### Step 1: Download

**Option A: From GitHub Releases**
1. Go to: https://github.com/tponsky/MacCleanup/releases
2. Download: `MacCleanup-1.0.dmg`

**Option B: Direct Download**
- Download link: https://github.com/tponsky/MacCleanup/releases/latest/download/MacCleanup-1.0.dmg

### Step 2: Install

1. **Double-click** the `MacCleanup-1.0.dmg` file
2. **Drag** `MacCleanup.app` to your **Applications** folder
3. **Double-click** `MacCleanup.app` to launch
4. Your browser opens automatically at `http://localhost:5050`

### Step 3: First-Time Setup

**Important:** MacCleanup needs to know where your files are stored!

#### Quick Setup (Recommended)

Run the setup wizard:

1. Right-click `MacCleanup.app` → **Show Package Contents**
2. Navigate to: `Contents/Resources/`
3. Open Terminal in that folder:
   ```bash
   cd /Applications/MacCleanup.app/Contents/Resources
   python3 setup_wizard.py
   ```

The wizard will:
- Detect your Dropbox folder automatically
- Detect your external drives
- Ask you to configure paths
- Save your configuration

#### Manual Setup

1. Right-click `MacCleanup.app` → **Show Package Contents**
2. Navigate to: `Contents/Resources/`
3. Open `config.py` in a text editor
4. Update these paths:

```python
# Your Dropbox path (or iCloud Drive, or None)
DROPBOX_ROOT = HOME / "Dropbox" / "Your Name"

# Your external drive (or None if you don't use one)
SSD_ROOT = Path("/Volumes/Your Drive Name")
```

---

## 🚀 From Source (For Developers)

### Prerequisites
- macOS (any recent version)
- Python 3.8+ (usually pre-installed)
- Git (optional, for cloning)

### Installation Steps

1. **Clone or Download:**
   ```bash
   git clone https://github.com/tponsky/MacCleanup.git
   cd MacCleanup
   ```
   Or download ZIP from GitHub and extract it.

2. **Set up Python environment:**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Run setup wizard:**
   ```bash
   python3 setup_wizard.py
   ```
   This helps configure Dropbox/iCloud and external drive paths.

4. **Launch the app:**
   ```bash
   ./start.sh
   ```
   Or double-click `MacCleanup.app` in Applications folder.

---

## ⚙️ Configuration Guide

### Why Configuration is Needed

MacCleanup needs to know:
- Where your Dropbox/iCloud folder is located
- If you use an external drive (and its name)
- Where to organize your files

### Configuration Options

#### Option 1: Setup Wizard (Easiest)

```bash
python3 setup_wizard.py
```

The wizard:
- ✅ Detects Dropbox automatically
- ✅ Detects external drives
- ✅ Asks you to choose paths
- ✅ Saves configuration

#### Option 2: Edit config.py

Edit `config.py` and update:

```python
# Dropbox - choose one:
DROPBOX_ROOT = HOME / "Dropbox" / "Your Name"           # Standard Dropbox
DROPBOX_ROOT = HOME / "Library" / "Mobile Documents" / "com~apple~CloudDocs"  # iCloud Drive
DROPBOX_ROOT = None                                       # No cloud storage

# External Drive - choose one:
SSD_ROOT = Path("/Volumes/Your Drive Name")              # Your external drive
SSD_ROOT = None                                           # No external drive
```

#### Option 3: User Config File

Create `user_config.json` in the MacCleanup folder:

```json
{
  "dropbox_root": "/Users/YourName/Dropbox",
  "ssd_root": "/Volumes/My External Drive"
}
```

Or set to `null` if you don't use them:

```json
{
  "dropbox_root": null,
  "ssd_root": null
}
```

---

## 🔧 Common Configurations

### Using Dropbox
```python
DROPBOX_ROOT = HOME / "Dropbox" / "Your Name"
SSD_ROOT = None  # Or your external drive path
```

### Using iCloud Drive
```python
DROPBOX_ROOT = HOME / "Library" / "Mobile Documents" / "com~apple~CloudDocs"
SSD_ROOT = None  # Or your external drive path
```

### No Cloud Storage
```python
DROPBOX_ROOT = None
SSD_ROOT = Path("/Volumes/My External Drive")  # Or None
```

### Full Setup (Dropbox + External Drive)
```python
DROPBOX_ROOT = HOME / "Dropbox" / "Your Name"
SSD_ROOT = Path("/Volumes/My External Drive")
```

---

## 📋 First Launch Checklist

- [ ] Download and install `MacCleanup.app`
- [ ] Run setup wizard OR edit `config.py`
- [ ] Launch the app
- [ ] Browser opens at `http://localhost:5050`
- [ ] Click "Preview Cleanup" to see what will be cleaned
- [ ] Review and select actions
- [ ] Click "Run Cleanup"

---

## 🐛 Troubleshooting

### "Dropbox not found" or "SSD not found"

**Solution:** Configure your paths!
1. Run `python3 setup_wizard.py`
2. Or edit `config.py` to match your paths
3. Make sure paths exist (check in Finder)

### "Port 5050 already in use"

**Solution:** Another app is using port 5050
- Close other apps using that port
- Or edit `app.py` and change `port=5050` to a different number

### "Permission denied"

**Solution:** Make scripts executable
```bash
chmod +x start.sh setup_scheduler.sh auto_cleanup.py
```

### App won't open (Gatekeeper)

**Solution:** Right-click `MacCleanup.app` → **Open** → Click **"Open"** in the dialog

### "Module not found" or import errors

**Solution:** Install dependencies
```bash
cd /Applications/MacCleanup.app/Contents/Resources
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
```

---

## ✅ Verification

After installation, verify everything works:

1. Launch the app
2. Browser opens at `http://localhost:5050`
3. You should see:
   - ✅ Desktop, Downloads, Documents folders listed
   - ✅ File counts and sizes
   - ✅ Dropbox/SSD status indicators

If you see errors, check:
- Python is installed: `python3 --version`
- Dependencies installed: Check `venv` folder exists
- Paths configured: Check `config.py` or `user_config.json`

---

## 📚 Next Steps

- Read [README.md](README.md) for features overview
- See [ARCHIVING_EXPLAINED.md](ARCHIVING_EXPLAINED.md) to understand archiving
- Set up [automatic cleanup](README.md#automatic-cleanup) for weekly runs

---

**Need Help?** Open an issue on GitHub: https://github.com/tponsky/MacCleanup/issues

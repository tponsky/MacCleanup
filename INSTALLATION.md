# MacCleanup Installation Guide

## For End Users (Non-Developers)

### Option 1: Using DMG Installer (Easiest)

1. Download `MacCleanup-1.0.dmg` from GitHub Releases
2. Double-click the DMG file
3. Drag `MacCleanup.app` to your Applications folder
4. Double-click `MacCleanup.app` to launch
5. Browser opens automatically at `http://localhost:5050`

**First Launch:**
- The app will automatically install Python dependencies
- This takes about 1-2 minutes
- You'll see a notification when ready

---

### Option 2: From GitHub (For Developers)

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

3. **Make scripts executable:**
   ```bash
   chmod +x start.sh setup_scheduler.sh auto_cleanup.py
   ```

4. **Configure (if needed):**
   - Edit `config.py` to match your Dropbox path
   - Update `SSD_ROOT` if you use a different external drive

5. **Launch:**
   ```bash
   ./start.sh
   ```

---

## Configuration

### Update Dropbox Path

If your Dropbox is in a different location, edit `config.py`:

```python
# Change this line:
DROPBOX_ROOT = HOME / "GlobalCastMD Dropbox" / "Todd Ponsky"

# To your Dropbox path, for example:
DROPBOX_ROOT = HOME / "Dropbox" / "Your Name"
```

### Update External SSD Path

If your external drive has a different name:

```python
# Change this line:
SSD_ROOT = Path("/Volumes/Extreme SSD")

# To your drive name:
SSD_ROOT = Path("/Volumes/Your Drive Name")
```

---

## Troubleshooting

### "Port 5050 already in use"
Another app is using port 5050. Either:
- Close the other app
- Or edit `app.py` and change `port=5050` to a different number

### "Dropbox not found"
- Make sure Dropbox is installed and running
- Update `DROPBOX_ROOT` in `config.py` to match your actual Dropbox path

### "Permission denied"
Run:
```bash
chmod +x start.sh setup_scheduler.sh auto_cleanup.py
```

### App won't open (Gatekeeper)
Right-click `MacCleanup.app` → Open → Click "Open" in the dialog.

---

## Features

- ✅ Web dashboard for file management
- ✅ Automatic cleanup of junk files
- ✅ Smart file organization
- ✅ Archive old files automatically
- ✅ Version detection for duplicates
- ✅ Selectable actions with checkboxes
- ✅ Scheduled automatic cleanup

---

## Support

- GitHub Issues: https://github.com/tponsky/MacCleanup/issues
- Documentation: See README.md in the repo

# How to Use MacCleanup

## Quick Reference Guide

### First Time Setup (You only do this once)

1. **Launch the app:**
   - Double-click `MacCleanup.app` in your Applications folder
   - Your browser opens automatically at `http://localhost:5050`

2. **Configure paths (first time only):**
   - Right-click `MacCleanup.app` → Show Package Contents
   - Navigate to: `Contents/Resources/`
   - Open Terminal in that folder:
     ```bash
     cd /Applications/MacCleanup.app/Contents/Resources
     python3 setup_wizard.py
     ```
   - The wizard detects your Dropbox/external drives and asks you to configure
   - This saves your configuration - you won't need to do it again

3. **That's it!** The app is now configured for your system.

---

### Using MacCleanup (Every Time You Want to Clean Up)

1. **Launch the app:**
   - Double-click `MacCleanup.app` in Applications
   - Browser opens at `http://localhost:5050`

2. **Preview what will be cleaned:**
   - Click **"Preview Cleanup"** button
   - The app scans your Desktop, Downloads, and Documents folders
   - Shows you what actions it suggests:
     - Move files to Dropbox/SSD
     - Delete junk files
     - Archive old files
     - etc.

3. **Review and select:**
   - Review each suggested action
   - Use checkboxes to select/deselect actions
   - "Select All" / "Deselect All" buttons available
   - See count: "X of Y selected"

4. **Run cleanup:**
   - Click **"Run Cleanup"** button
   - The app executes only the selected actions
   - Shows you a summary of what was done

5. **Done!** Your files are now organized.

---

### What the App Does

**Automatically:**
- Deletes junk files (`.DS_Store`, Office temp files, etc.)
- Moves presentations → `Dropbox/Work/Presentations/`
- Moves PDFs → `Dropbox/Reference/PDFs/`
- Moves screenshots → `Dropbox/Media/Screenshots/`
- Moves videos → External SSD (if configured)
- Archives old files → `Dropbox/Archive/`

**You Control:**
- Which actions to execute (checkboxes)
- When to run cleanup (manual or scheduled)
- Which files get organized (based on your configuration)

---

### Optional: Automatic Weekly Cleanup

If you want the app to run automatically every Monday at 9 AM:

1. Open Terminal
2. Navigate to app resources:
   ```bash
   cd /Applications/MacCleanup.app/Contents/Resources
   ```
3. Run scheduler setup:
   ```bash
   ./setup_scheduler.sh
   ```

To disable automatic cleanup:
```bash
launchctl unload ~/Library/LaunchAgents/com.maccleanup.auto.plist
```

---

### Troubleshooting

**App won't open:**
- Right-click `MacCleanup.app` → Open → Click "Open" (first time only, bypasses Gatekeeper)

**Port 5050 already in use:**
- Another app is using port 5050
- Close other apps, or the app will handle it automatically

**Dropbox not found:**
- Make sure Dropbox is installed and running
- Run setup wizard again to reconfigure paths

**Files not moving to expected locations:**
- Check your configuration in `config.py` or run setup wizard again
- Make sure paths exist (check in Finder)

---

### Key Points

✅ **Runs locally on your Mac** - no server, no cloud processing  
✅ **Your files stay on your computer** - organized, not uploaded anywhere  
✅ **You control everything** - select which actions to run  
✅ **Works offline** - no internet connection needed  
✅ **Safe** - previews before executing, you approve actions  

---

**That's it!** Just launch the app whenever you want to organize your files.

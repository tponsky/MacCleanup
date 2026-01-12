# How to Test MacCleanup

## Quick Test Guide

### Step 1: Test the App Locally

1. **Navigate to the project:**
   ```bash
   cd ~/CursorProjects/MacCleanup
   ```

2. **Activate virtual environment (if exists):**
   ```bash
   source venv/bin/activate
   ```

   Or create one if it doesn't exist:
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Test the setup wizard:**
   ```bash
   python3 setup_wizard.py
   ```
   
   This will:
   - Detect your Dropbox (if you have one)
   - Detect external drives (if plugged in)
   - Ask about drive usage (always connected vs sometimes disconnected)
   - Save configuration to `user_config.json`

4. **Launch the app:**
   ```bash
   python3 app.py
   ```
   
   Browser should open automatically at `http://localhost:5050`

5. **Test the web interface:**
   - Click "Preview Cleanup" button
   - Review suggested actions
   - Select/deselect actions using checkboxes
   - Click "Run Cleanup" (use with caution - it will actually move/delete files!)

---

### Step 2: Test the DMG Installer

1. **Create the DMG (if not already created):**
   ```bash
   cd ~/CursorProjects/MacCleanup
   ./create_dmg.sh
   ```

2. **Test the DMG:**
   - Double-click `MacCleanup-1.0.dmg`
   - Drag `MacCleanup.app` to your Applications folder
   - Double-click `MacCleanup.app` to launch
   - Browser should open at `http://localhost:5050`

3. **Test setup wizard from installed app:**
   ```bash
   cd /Applications/MacCleanup.app/Contents/Resources
   python3 setup_wizard.py
   ```

4. **Test that configuration works:**
   - Launch the app again
   - Click "Preview Cleanup"
   - Verify it uses your configured paths

---

### Step 3: Test External Drive Handling

1. **With drive connected:**
   - Plug in your external drive
   - Run setup wizard
   - Select the drive
   - Choose "always connected" or "sometimes disconnected"
   - Verify configuration saved correctly

2. **Test with drive disconnected (if you said "sometimes disconnected"):**
   - Unplug external drive
   - Launch app
   - Click "Preview Cleanup"
   - Verify app handles missing drive gracefully (should ask or skip)

---

### Step 4: Test Different Configurations

Test the setup wizard with different scenarios:

1. **Has Dropbox:**
   - Run wizard
   - Confirm Dropbox detection
   - Verify paths are correct

2. **No Dropbox (use iCloud):**
   - If you don't have Dropbox, or temporarily rename it
   - Run wizard
   - Choose iCloud Drive option
   - Verify configuration saved

3. **No cloud storage:**
   - Run wizard
   - Choose "skip cloud storage"
   - Verify app still works (may warn about no cloud storage)

4. **With external drive:**
   - Plug in external drive
   - Run wizard
   - Select drive
   - Choose "always connected" vs "sometimes disconnected"
   - Verify configuration saved correctly

---

## Testing Checklist

- [ ] App launches successfully
- [ ] Setup wizard runs without errors
- [ ] Dropbox detection works (if you have Dropbox)
- [ ] External drive detection works (if drive is plugged in)
- [ ] Configuration saves correctly (`user_config.json` created)
- [ ] App reads configuration correctly
- [ ] Web interface loads (`http://localhost:5050`)
- [ ] "Preview Cleanup" button works
- [ ] Checkboxes work (select/deselect)
- [ ] File scanning works (shows files from Desktop/Downloads/Documents)
- [ ] Suggested actions make sense
- [ ] DMG installer creates successfully
- [ ] DMG can be installed (drag to Applications)
- [ ] Installed app works correctly
- [ ] Configuration persists after app restart

---

## What to Test Specifically

### Setup Wizard

✅ Detects Dropbox automatically  
✅ Asks user to confirm/enter Dropbox path  
✅ Offers iCloud Drive option  
✅ Detects external drives  
✅ Asks if drive is always connected  
✅ Saves configuration correctly  

### App Functionality

✅ Web interface loads  
✅ Preview cleanup shows files  
✅ Checkboxes work  
✅ Select/deselect all buttons work  
✅ File descriptions are helpful  
✅ Version detection works (LATEST badges)  
✅ Suggested actions make sense  

### Configuration

✅ `user_config.json` is created  
✅ Paths are correct  
✅ App reads configuration correctly  
✅ Configuration persists after restart  

---

## Testing Safely

**⚠️ Important:** When testing "Run Cleanup":

1. **Start with a test folder:**
   - Create a test folder with sample files
   - Don't test on your real Desktop/Downloads at first

2. **Use Preview mode first:**
   - Always click "Preview Cleanup" first
   - Review all suggested actions
   - Make sure actions make sense

3. **Select actions carefully:**
   - Don't select "Select All" on your first test
   - Select a few safe actions first
   - Test with non-important files

4. **Have a backup:**
   - Backup important files before testing
   - Test with files you can recreate if needed

---

## Common Issues to Test For

### Configuration Issues

- **Dropbox not detected:** Does wizard offer manual entry?
- **External drive not detected:** Does wizard handle gracefully?
- **Invalid paths:** Does app handle missing paths?

### App Issues

- **Port 5050 in use:** Does app handle this gracefully?
- **Missing dependencies:** Does app show helpful error?
- **Configuration missing:** Does app suggest running setup wizard?

---

## Quick Test Command

Run this to test everything quickly:

```bash
cd ~/CursorProjects/MacCleanup
source venv/bin/activate  # If venv exists
python3 setup_wizard.py   # Test setup wizard
python3 app.py            # Test app (in another terminal or background)
```

Then open `http://localhost:5050` in your browser.

---

**Need help?** Check the logs or error messages - they should be helpful!

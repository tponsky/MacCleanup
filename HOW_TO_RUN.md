# How to Run MacCleanup - Simple Instructions

## 🎯 Quick Start (Easiest Way)

### Step 1: Download and Install

1. **Download** the `MacCleanup-1.0.dmg` file
2. **Double-click** the DMG file to open it
3. **Drag** `MacCleanup.app` to your **Applications** folder
4. **Done!** The app is now installed

### Step 2: Launch the App

1. **Open** your **Applications** folder (click Finder → Applications)
2. **Find** `MacCleanup.app`
3. **Double-click** `MacCleanup.app`
4. **Your browser opens automatically** at `http://localhost:5050`

**That's it!** The app is now running.

---

## 🆕 First Time Setup

**If this is your first time:**

1. **Launch the app** (double-click `MacCleanup.app`)
2. **Browser opens** - you'll see a setup page automatically
3. **Fill out the form:**
   - Dropbox folder (auto-detected, or enter manually)
   - External drive (if you have one plugged in)
   - Check "Drive is always connected" if your drive stays plugged in
4. **Click "Save Configuration"**
5. **Done!** You're now at the main dashboard

**You only do this once!** After that, the app opens directly to the main dashboard.

---

## 📱 Using MacCleanup

**Every time you want to clean up your files:**

1. **Double-click** `MacCleanup.app` in Applications
2. **Browser opens** automatically
3. **Click "Preview Cleanup"** to see what needs organizing
4. **Select** the actions you want (using checkboxes)
5. **Click "Run Cleanup"** to execute

**That's it!** Your files are now organized.

---

## ❓ Common Questions

### "I don't see MacCleanup.app in Applications"

**Fix:** Make sure you dragged it from the DMG to Applications. If not:
1. Open the DMG file again
2. Drag `MacCleanup.app` to Applications folder
3. Try launching again

### "App won't open" (Gatekeeper warning)

**Fix:** Right-click `MacCleanup.app` → **Open** → Click **"Open"** in the dialog

**Why?** macOS blocks apps from unknown developers. This is normal the first time.

### "Browser doesn't open automatically"

**Fix:** Manually open your browser and go to: `http://localhost:5050`

### "Setup page doesn't appear"

**Fix:** The setup page only appears the first time. If you've already set it up:
- The main dashboard appears directly
- You're all set!

### "I want to change my configuration"

**Fix:** You can re-run setup by deleting `user_config.json`:
1. Right-click `MacCleanup.app` → **Show Package Contents**
2. Navigate to: `Contents/Resources/`
3. Delete `user_config.json`
4. Launch the app again - setup page appears

---

## 🎯 Summary

**To run MacCleanup:**
1. **Download** DMG → **Drag** to Applications
2. **Double-click** `MacCleanup.app`
3. **Browser opens** automatically
4. **Fill setup form** (first time only)
5. **Use the app!**

**No Terminal, no Python commands - just click and go!** ✅

---

**That's it!** It's that simple. 🎉

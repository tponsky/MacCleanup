# Testing MacCleanup From Scratch

## 🎯 Goal
Test the entire user experience from beginning to end, as if you're a new user.

## ✅ What to Keep (DO NOT DELETE!)

**Keep your development folder:**
- `/Users/toddponskymd/CursorProjects/MacCleanup`
- This contains all your code
- **Don't delete this!**

## ❌ What to Delete (To Test Fresh)

### Step 1: Delete Installed App (if it exists)

1. **Open Applications folder:**
   - Finder → Applications
   - Or press `Cmd+Shift+A`

2. **Find `MacCleanup.app`**
3. **Delete it:**
   - Drag to Trash
   - Or right-click → Move to Trash

**Check if it exists:**
```bash
ls -la /Applications/MacCleanup.app
```

If it exists, delete it. If not, you're good!

### Step 2: Config Already Removed ✅

**Already done!** The `user_config.json` file has been moved to backup, so the setup page will appear.

---

## 🧪 Testing Flow

### Step 1: Install Fresh

1. **Go to MacCleanup folder:**
   - `/Users/toddponskymd/CursorProjects/MacCleanup`

2. **Find `MacCleanup-1.0.dmg`**

3. **Double-click `MacCleanup-1.0.dmg`**
   - DMG opens

4. **Drag `MacCleanup.app` to Applications**
   - Installation complete!

### Step 2: Launch for First Time

1. **Go to Applications folder**
2. **Double-click `MacCleanup.app`**
3. **Browser opens automatically**
4. **Setup page appears** (because no config exists)

### Step 3: Complete Setup

1. **Fill out setup form:**
   - Dropbox path (auto-detected or enter manually)
   - External drive (if you have one)
   - Check "Drive always connected" if applicable

2. **Click "Save Configuration"**
3. **Redirects to main dashboard**

### Step 4: Test the App

1. **Click "Preview Cleanup"**
2. **Review suggested actions**
3. **Select actions using checkboxes**
4. **Click "Run Cleanup"** (be careful - actually moves/deletes files!)

---

## 📋 Checklist

- [ ] Deleted `/Applications/MacCleanup.app` (if it existed)
- [ ] `user_config.json` removed (already done ✅)
- [ ] Double-click `MacCleanup-1.0.dmg`
- [ ] Drag `MacCleanup.app` to Applications
- [ ] Double-click `MacCleanup.app` to launch
- [ ] Setup page appears
- [ ] Fill out setup form
- [ ] Click "Save Configuration"
- [ ] Main dashboard loads
- [ ] Test "Preview Cleanup"
- [ ] Test selecting actions
- [ ] Test "Run Cleanup"

---

## 🎯 Summary

**To test from scratch:**
1. Delete `/Applications/MacCleanup.app` (if it exists)
2. Install fresh from DMG
3. Launch app
4. Setup page appears automatically
5. Complete setup
6. Test the app!

**DO NOT delete the development folder!** Just delete the installed app.

---

**Ready to test!** 🚀

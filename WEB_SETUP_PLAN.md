# Web-Based Setup Wizard Plan

## Goal
Create a beautiful web-based setup wizard that appears automatically when user_config.json doesn't exist. No terminal, no Python commands - just click and go!

## User Flow
1. User downloads DMG → drags to Applications
2. Double-clicks MacCleanup.app → browser opens automatically
3. **If first time:** Beautiful setup page appears automatically
4. User fills form → clicks "Save Configuration"
5. Config saved → redirects to main dashboard
6. **If already configured:** Main dashboard shows directly

## Implementation Steps

### 1. Add imports
- Import setup_wizard functions (detect_dropbox, detect_external_drives)

### 2. Create Setup Template
- SETUP_TEMPLATE constant (matching HTML_TEMPLATE style)
- Beautiful dark theme UI
- Form with:
  - Dropbox path (auto-detected, editable)
  - External drive (auto-detected, editable, checkbox for "always connected")
  - Save button

### 3. Add API Endpoints
- `/api/setup/detect` - Detects Dropbox/external drives
- `/api/setup/save` - Saves user_config.json

### 4. Modify Index Route
- Check if user_config.json exists
- If not: return SETUP_TEMPLATE
- If yes: return HTML_TEMPLATE (main dashboard)

### 5. Add JavaScript to Setup Page
- Auto-load detected paths on page load
- Form validation
- Save config → redirect to main dashboard

## Files to Modify
- app.py (add setup UI, API endpoints, modify index route)

## Benefits
- ✅ No terminal required
- ✅ No Python commands
- ✅ Beautiful UI (matches existing)
- ✅ Automatic detection
- ✅ Super easy for non-technical users
- ✅ Works on first launch automatically

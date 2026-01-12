# Upload DMG to GitHub Releases

## Quick Steps to Share via GitHub Releases

1. **Go to GitHub Releases:**
   - Visit: https://github.com/tponsky/MacCleanup/releases
   - Or: Click "Releases" on the GitHub repo page

2. **Create New Release:**
   - Click "Draft a new release" button (or "Create a new release")
   
3. **Fill in Release Details:**
   - **Tag version:** `v1.0`
   - **Release title:** `MacCleanup v1.0`
   - **Description:**
   ```
   ## MacCleanup v1.0 - File Organization Tool
   
   A beautiful web-based file cleanup tool for macOS.
   
   ### Installation
   1. Download MacCleanup-1.0.dmg
   2. Double-click to open
   3. Drag MacCleanup.app to Applications
   4. Double-click MacCleanup.app to launch
   5. Configure your paths (see INSTALLATION.md)
   
   ### Features
   - Visual dashboard for file management
   - Automatic cleanup of junk files
   - Smart file organization
   - Dropbox/iCloud integration
   - External SSD support
   - Scheduled automatic cleanup
   
   ### Documentation
   See README.md and INSTALLATION.md for detailed instructions.
   ```

4. **Upload DMG:**
   - Drag and drop `MacCleanup-1.0.dmg` into the "Attach binaries" section
   - Or click "Attach binaries" and select the DMG file

5. **Publish:**
   - Click "Publish release"
   - Done! The DMG is now available for download

## After Publishing

Users can download from:
- https://github.com/tponsky/MacCleanup/releases/latest
- Or: https://github.com/tponsky/MacCleanup/releases/latest/download/MacCleanup-1.0.dmg

---

## Creating New Releases (Future Versions)

When you make updates:

1. Update version in code/scripts
2. Run `./create_dmg.sh` to create new DMG
3. Create new release with version tag (e.g., `v1.1`)
4. Upload new DMG file

---

**Current DMG Location:** `~/CursorProjects/MacCleanup/MacCleanup-1.0.dmg`

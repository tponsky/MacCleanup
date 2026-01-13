# MacCleanup Deployment Notes

## Latest Deployment - January 13, 2026

### Website Updates (computercleanup.staycurrentai.com)

#### ✅ Simplified Installation Guide
- **Changed from:** Complex multi-step wizard instructions
- **Changed to:** Simple 5-step process:
  1. Download - Click the download button
  2. Drag to Applications - Visual guide image added
  3. Open from Applications - Launch the app
  4. Setup Preferences - Answer questions on setup page
  5. Start Cleaning Up - Use the cleanup dashboard

#### ✅ Visual Improvements
- **Added:** Professional drag-to-install image (`drag-to-applications.png`)
  - 728x388 canvas with rounded card border
  - MacCleanup app icon with gradient (#1D1020 → #7A1D3A → #D43A52)
  - Red arrow pointing to Applications folder
  - Applications folder with blue gradient and badge
  - Matches JSON specification exactly

- **Added:** Favicon (`favicon.ico`)
  - 32x32 icon with "MC" logo on purple gradient
  - Fixes 404 error for favicon.ico

#### ✅ Content Updates
- Removed all references to "wizard" (now uses "setup page")
- Removed manual Terminal setup instructions
- Removed inaccessible `setup_scheduler.sh` section
- Updated terminology to match current app behavior
- Added explanation of what MacCleanup does
- Clarified two-page navigation (Setup Page + Cleanup Dashboard)

#### ✅ HTTPS Configuration
- Enabled HTTPS for `computercleanup.staycurrentai.com`
- SSL certificate installed (Let's Encrypt)
- HTTP → HTTPS redirect enabled
- Certificate expires: 2026-04-13
- Auto-renewal configured

### Files Changed
- `website/index.html` - Complete rewrite of installation guide
- `website/drag-to-applications.png` - New visual guide image
- `website/favicon.ico` - New favicon

### Deployment Location
- **Website:** https://computercleanup.staycurrentai.com
- **Server:** AWS EC2 (3.14.156.143)
- **Web Root:** `/var/www/maccleanup/`
- **Web Server:** Apache (httpd)

### GitHub Updates
- All changes committed and pushed to main/master branch
- Commit message includes full summary of changes

### Next Steps (Optional)
- Consider adding `setup_scheduler.sh` to app bundle if automatic scheduling is desired
- Monitor website analytics for user feedback
- Update DMG installer if needed to match website instructions

---

## Previous Deployments

### Initial Website Deployment
- Created landing page with download link
- Set up Apache virtual host
- Configured DMG file serving
- Basic installation instructions

---

## Deployment Commands Reference

### Deploy Website to EC2
```bash
cd website
scp index.html drag-to-applications.png favicon.ico ec2-user@3.14.156.143:/tmp/
ssh ec2-user@3.14.156.143 "sudo mv /tmp/index.html /tmp/drag-to-applications.png /tmp/favicon.ico /var/www/maccleanup/ && sudo chmod 644 /var/www/maccleanup/*"
```

### Enable HTTPS (if needed)
```bash
ssh ec2-user@3.14.156.143 "sudo certbot --apache -d computercleanup.staycurrentai.com --non-interactive --agree-tos --email tponsky@gmail.com --redirect"
```

### Check Website Status
```bash
curl -I https://computercleanup.staycurrentai.com
```

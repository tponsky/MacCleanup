# Code Signing MacCleanup with Apple Developer Certificate

## Overview

To avoid the macOS Gatekeeper warning, you can code-sign the MacCleanup app with an Apple Developer certificate.

## Requirements

1. **Apple Developer Account** ($99/year)
   - Sign up at: https://developer.apple.com
   
2. **Certificate installed on your Mac**
   - Download from Apple Developer Portal
   - Install in Keychain Access

3. **Signing identity**
   - Usually: "Developer ID Application: Your Name (TEAM_ID)"

## Steps

### 1. Check if certificate is installed

```bash
security find-identity -v -p codesigning
```

Look for: `Developer ID Application: ...`

### 2. Code-sign the app

```bash
codesign --deep --force --verify --verbose \
  --sign "Developer ID Application: Your Name (TEAM_ID)" \
  /Applications/MacCleanup.app
```

### 3. Verify signature

```bash
codesign --verify --verbose /Applications/MacCleanup.app
spctl --assess --verbose /Applications/MacCleanup.app
```

### 4. Update build script

Add code signing to `create_installer.sh`:

```bash
# Code-sign the app
CODESIGN_IDENTITY="Developer ID Application: Your Name (TEAM_ID)"
codesign --deep --force --verify --verbose \
  --sign "$CODESIGN_IDENTITY" \
  "$APP_PATH"
```

## Benefits

- ✅ No Gatekeeper warning
- ✅ Users can double-click to open
- ✅ Better user experience
- ✅ More professional

## Note

You'll need to re-sign the app after each build/update.


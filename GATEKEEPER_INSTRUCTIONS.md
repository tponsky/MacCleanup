# macOS Security Warning - How to Open MacCleanup

When you first try to open MacCleanup, macOS will show a security warning:

> **"Apple could not verify 'MacCleanup' is free of malware..."**

This is normal for apps that aren't signed with an Apple Developer certificate (which costs $99/year).

## ✅ How to Open the App (Choose One Method)

### Method 1: Right-Click and Open (Easiest)

1. **Don't double-click** the app yet
2. **Right-click** (or Control-click) on `MacCleanup.app`
3. Select **"Open"** from the menu
4. You'll see another warning - click **"Open"** again
5. The app will launch!

After the first time, you can double-click normally.

---

### Method 2: System Settings

1. Try to open the app (you'll see the error)
2. Go to **System Settings** → **Privacy & Security**
3. Scroll down - you'll see a message: **"'MacCleanup' was blocked..."**
4. Click **"Open Anyway"** button next to it
5. Confirm by clicking **"Open"**
6. The app will launch!

---

### Method 3: Terminal (Advanced)

If you're comfortable with Terminal:

```bash
xattr -d com.apple.quarantine /Applications/MacCleanup.app
```

Then double-click the app normally.

---

## 🔒 Why This Happens

macOS Gatekeeper blocks apps that aren't signed by Apple or an Apple Developer. This is a security feature, but it affects free/open-source apps that don't have a $99/year Apple Developer certificate.

**MacCleanup is safe** - it's just not code-signed because we're not paying Apple $99/year for a developer certificate.

---

## ✅ After First Launch

Once you've opened the app once using any method above, macOS will remember it and you can double-click normally in the future!

---

## 📝 Note

These instructions will be included on the download website and in the DMG installer.

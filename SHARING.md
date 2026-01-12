# Sharing MacCleanup with Others

## Quick Share Options

### Option 1: Share GitHub Link (Easiest)
Just share this link: **https://github.com/tponsky/MacCleanup**

Others can:
1. Clone the repo
2. Follow the setup instructions below
3. Start using it

---

### Option 2: Create a DMG Installer (Best for Non-Technical Users)
See instructions below to create a `.dmg` file that others can double-click to install.

---

## Setup Instructions for Others

### Prerequisites
- macOS (any recent version)
- Python 3 (usually pre-installed on Mac)
- Dropbox (optional, but recommended)

### Installation Steps

1. **Clone or Download the Repo**
   ```bash
   git clone https://github.com/tponsky/MacCleanup.git
   cd MacCleanup
   ```
   
   Or download ZIP from GitHub and extract it.

2. **Set Up Python Environment**
   ```bash
   python3 -m venv venv
   source venv/bin/activate
   pip install -r requirements.txt
   ```

3. **Make Scripts Executable**
   ```bash
   chmod +x start.sh setup_scheduler.sh auto_cleanup.py
   ```

4. **Configure for Their System**
   - Edit `config.py` to match their Dropbox path
   - Update `DROPBOX_ROOT` if they use a different Dropbox location
   - Update `SSD_ROOT` if they use a different external drive name

5. **Launch the App**
   ```bash
   ./start.sh
   ```
   
   Or double-click `MacCleanup.app` in Applications folder (if you create the installer).

---

## Creating a DMG Installer (For Easy Distribution)

This creates a professional installer that others can use.

"""Configuration for MacCleanup app"""
import os
import json
from pathlib import Path

# User home directory
HOME = Path.home()

# Load user configuration if it exists
USER_CONFIG_FILE = Path(__file__).parent / "user_config.json"
user_config = {}
if USER_CONFIG_FILE.exists():
    try:
        with open(USER_CONFIG_FILE, 'r') as f:
            user_config = json.load(f)
    except:
        pass

# Directories to monitor and clean
WATCHED_DIRS = {
    "desktop": HOME / "Desktop",
    "downloads": HOME / "Downloads",
    "documents": HOME / "Documents",
}

# Dropbox path - use user config or default
if user_config.get('dropbox_root'):
    DROPBOX_ROOT = Path(user_config['dropbox_root'])
else:
    # Default - can be overridden by user
    DROPBOX_ROOT = HOME / "GlobalCastMD Dropbox" / "Todd Ponsky"

# External SSD path - use user config or default
if user_config.get('ssd_root'):
    SSD_ROOT = Path(user_config['ssd_root'])
else:
    # Default - can be overridden by user
    SSD_ROOT = Path("/Volumes/Extreme SSD")

# Dropbox folder structure (only if Dropbox exists)
DROPBOX_FOLDERS = {
    "presentations": DROPBOX_ROOT / "Work" / "Presentations",
    "pdfs": DROPBOX_ROOT / "Reference" / "PDFs",
    "documents": DROPBOX_ROOT / "Work",
    "screenshots": DROPBOX_ROOT / "Media" / "Screenshots",
    "archive": DROPBOX_ROOT / "Archive",
} if DROPBOX_ROOT.exists() else {}

# SSD folder structure (only if SSD exists)
SSD_FOLDERS = {
    "videos": SSD_ROOT / "Videos" / "To-Review",
    "ai_demos": SSD_ROOT / "Videos" / "AI-Demos",
    "presentations": SSD_ROOT / "Videos" / "Presentations",
    "personal": SSD_ROOT / "Videos" / "Personal",
} if SSD_ROOT.exists() else {}

# File categories and their extensions
FILE_CATEGORIES = {
    "presentations": [".pptx", ".ppt", ".key"],
    "documents": [".docx", ".doc", ".txt", ".rtf", ".pages"],
    "spreadsheets": [".xlsx", ".xls", ".csv", ".numbers"],
    "pdfs": [".pdf"],
    "images": [".png", ".jpg", ".jpeg", ".gif", ".webp", ".heic", ".tiff"],
    "videos": [".mp4", ".mov", ".m4v", ".avi", ".mkv", ".wmv"],
    "audio": [".mp3", ".m4a", ".wav", ".aiff", ".flac"],
    "archives": [".zip", ".tar", ".gz", ".rar", ".7z", ".dmg"],
    "installers": [".pkg", ".dmg", ".app"],
}

# Files to always delete (junk)
JUNK_PATTERNS = [
    "~$*",           # Office temp files
    ".DS_Store",     # macOS metadata
    "*.tmp",         # Temp files
    "Thumbs.db",     # Windows thumbnails
    ".localized",    # macOS localization
]

# Screenshot patterns
SCREENSHOT_PATTERNS = [
    "Screenshot*.png",
    "Screenshot*.jpg",
    "Screenshot*.jpeg",
    "Screen Shot*.png",
    "Screen Recording*.mov",
]

# Age thresholds (in days)
SCREENSHOT_MAX_AGE = 30  # Archive screenshots older than 30 days
DOWNLOADS_MAX_AGE = 90   # Flag downloads older than 90 days

# Size thresholds (in MB)
LARGE_FILE_THRESHOLD = 100  # Flag files larger than 100MB

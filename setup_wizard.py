#!/usr/bin/env python3
"""
Configuration Wizard for MacCleanup
Helps users configure the app for their system on first run
"""
import os
import sys
from pathlib import Path
import json

CONFIG_FILE = Path(__file__).parent / "user_config.json"
CONFIG_PY = Path(__file__).parent / "config.py"

def detect_dropbox():
    """Try to detect Dropbox location"""
    home = Path.home()
    common_paths = [
        home / "Dropbox",
        home / "GlobalCastMD Dropbox",
        home / "Dropbox (Personal)",
        home / "Dropbox (Business)",
    ]
    
    for path in common_paths:
        if path.exists():
            return path
    
    # Check for Dropbox folder in common locations
    for item in home.iterdir():
        if "Dropbox" in item.name and item.is_dir():
            return item
    
    return None

def detect_external_drives():
    """Detect external drives"""
    volumes = Path("/Volumes")
    drives = []
    
    if volumes.exists():
        for item in volumes.iterdir():
            if item.name not in ["Macintosh HD", "Macintosh HD - Data"]:
                if item.is_dir() and not item.name.startswith('.'):
                    drives.append(item.name)
    
    return drives

def get_user_input(prompt, default=None, validator=None):
    """Get user input with optional default and validation"""
    if default:
        full_prompt = f"{prompt} [{default}]: "
    else:
        full_prompt = f"{prompt}: "
    
    while True:
        value = input(full_prompt).strip()
        if not value and default:
            value = default
        
        if value:
            if validator:
                if validator(value):
                    return value
                else:
                    print("Invalid input. Please try again.")
            else:
                return value
        else:
            print("Please enter a value.")

def validate_path(path_str):
    """Validate that path exists"""
    path = Path(path_str)
    if path.exists():
        return True
    else:
        print(f"Warning: Path does not exist: {path}")
        response = input("Use this path anyway? (y/n): ").strip().lower()
        return response == 'y'

def main():
    """Run configuration wizard"""
    print("=" * 60)
    print("MacCleanup Configuration Wizard")
    print("=" * 60)
    print()
    print("Let's configure MacCleanup for your system.")
    print()
    
    config = {}
    
    # Detect Dropbox
    print("📍 Detecting Dropbox...")
    dropbox_path = detect_dropbox()
    if dropbox_path:
        print(f"   Found: {dropbox_path}")
        use = input(f"   Use this Dropbox folder? (Y/n): ").strip().lower()
        if use != 'n':
            config['dropbox_root'] = str(dropbox_path)
        else:
            config['dropbox_root'] = get_user_input("Enter your Dropbox folder path", validator=validate_path)
    else:
        print("   Dropbox not found automatically")
        print("   Options:")
        print("   1. Enter your Dropbox path")
        print("   2. Use iCloud Drive instead")
        print("   3. Skip cloud storage")
        choice = input("   Choice (1/2/3): ").strip()
        
        if choice == "1":
            config['dropbox_root'] = get_user_input("Enter your Dropbox folder path", validator=validate_path)
        elif choice == "2":
            config['dropbox_root'] = str(Path.home() / "Library" / "Mobile Documents" / "com~apple~CloudDocs")
            print(f"   Using iCloud Drive: {config['dropbox_root']}")
        else:
            config['dropbox_root'] = None
            print("   Cloud storage disabled")
    
    print()
    
    # Detect external drives
    print("💾 Detecting external drives...")
    drives = detect_external_drives()
    if drives:
        print(f"   Found: {', '.join(drives)}")
        print()
        print("   If you want to use an external drive, please make sure it's plugged in now.")
        use_drive = input(f"   Use external drive for large files (videos, etc.)? (Y/n): ").strip().lower()
        if use_drive != 'n':
            if len(drives) == 1:
                selected_drive = drives[0]
                config['ssd_root'] = f"/Volumes/{selected_drive}"
                print(f"   Using: {config['ssd_root']}")
            else:
                print("   Available drives:")
                for i, drive in enumerate(drives, 1):
                    print(f"   {i}. {drive}")
                choice = get_user_input(f"   Select drive (1-{len(drives)})", validator=lambda x: x.isdigit() and 1 <= int(x) <= len(drives))
                selected_drive = drives[int(choice)-1]
                config['ssd_root'] = f"/Volumes/{selected_drive}"
            
            print()
            print("   Important: Will this drive always be plugged in?")
            print("   - Always connected (storage only): App will move files here")
            print("   - Sometimes disconnected (active use): App will ask before moving files")
            drive_always = input(f"   Will '{selected_drive}' always be connected? (Y/n): ").strip().lower()
            config['ssd_always_connected'] = (drive_always != 'n')
            
            if config['ssd_always_connected']:
                print(f"   ✓ Drive will always be connected - files can be moved automatically")
            else:
                print(f"   ⚠ Drive may be disconnected - app will ask before moving files")
        else:
            config['ssd_root'] = None
            config['ssd_always_connected'] = False
    else:
        print("   No external drives found")
        print("   💡 Tip: If you have an external drive, plug it in and run this wizard again")
        config['ssd_root'] = None
        config['ssd_always_connected'] = False
    
    print()
    
    # Save configuration
    print("💾 Saving configuration...")
    with open(CONFIG_FILE, 'w') as f:
        json.dump(config, f, indent=2)
    
    print("✅ Configuration saved!")
    print()
    print("You can edit user_config.json to change settings later.")
    print()
    print("Starting MacCleanup...")
    print()
    
    return config

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("\n\nConfiguration cancelled.")
        sys.exit(0)

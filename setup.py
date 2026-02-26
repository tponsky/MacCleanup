"""
Setup script for py2app to create standalone Mac app bundle
This bundles Python and all dependencies into a self-contained .app
"""
from setuptools import setup
import os
import sys

# Get the directory containing this script
APP = 'app.py'
DATA_FILES = []
OPTIONS = {
    'argv_emulation': False,
    'packages': ['flask', 'watchdog', 'werkzeug', 'jinja2', 'itsdangerous', 'blinker', 'markupsafe', 'click'],
    'includes': ['cleanup_engine', 'config', 'setup_wizard', 'schedule'],
    'iconfile': None,  # Will be set by build script if icon exists
    'plist': {
        'CFBundleName': 'MacCleanup',
        'CFBundleDisplayName': 'MacCleanup',
        'CFBundleIdentifier': 'com.maccleanup.app',
        'CFBundleVersion': '1.0',
        'CFBundleShortVersionString': '1.0',
        'CFBundlePackageType': 'APPL',
        'LSMinimumSystemVersion': '10.13',
        'NSHighResolutionCapable': True,
        'NSHumanReadableCopyright': 'Copyright © 2024 MacCleanup',
    },
}

setup(
    name='MacCleanup',
    app=[APP],  # Must be a list for py2app
    data_files=DATA_FILES,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
)

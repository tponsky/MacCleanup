#!/bin/bash
# Update create_dmg.sh to include code signing

CODESIGN_IDENTITY="Developer ID Application: Bobbin LLC (8YY98N4P3K)"

echo "Updating create_dmg.sh to code-sign the app..."
echo "Using identity: $CODESIGN_IDENTITY"

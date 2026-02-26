#!/bin/bash
# ============================================================
# Duplicate File Finder for Todd's Mac
# Scans key folders for files with identical names or sizes
# Run: bash ~/CursorProjects/MacCleanup/find_duplicates.sh
# ============================================================

echo "============================================"
echo "  Duplicate File Finder"
echo "  $(date '+%Y-%m-%d %H:%M')"
echo "============================================"
echo ""

# Folders to scan
FOLDERS=(
    "$HOME/Desktop"
    "$HOME/Downloads"
    "$HOME/Documents"
    "$HOME/Videos to Convert"
    "$HOME/GlobalCastMD Dropbox/Todd Ponsky/Archive/a Weekly-Dump"
)

REPORT="$HOME/Desktop/duplicate_report_$(date '+%Y%m%d').txt"

echo "Scanning for duplicates..." 
echo "Duplicate File Report - $(date)" > "$REPORT"
echo "==========================================" >> "$REPORT"
echo "" >> "$REPORT"

# --- PASS 1: Find files with identical names across different folders ---
echo "" >> "$REPORT"
echo "=== FILES WITH SAME NAME IN MULTIPLE LOCATIONS ===" >> "$REPORT"
echo "" >> "$REPORT"

# Build a list of all files with their paths
temp_file=$(mktemp)
for folder in "${FOLDERS[@]}"; do
    if [ -d "$folder" ]; then
        find "$folder" -maxdepth 4 -type f \
            -not -name ".DS_Store" \
            -not -name "*.hazelrules" \
            -not -name "*.hazeldb" \
            -not -path "*/.*" \
            -print0 2>/dev/null | while IFS= read -r -d '' file; do
            basename=$(basename "$file")
            echo "$basename|$file"
        done
    fi
done | sort > "$temp_file"

# Find names that appear more than once
prev_name=""
prev_line=""
found_dupes=0
while IFS='|' read -r name path; do
    if [ "$name" = "$prev_name" ]; then
        if [ $found_dupes -eq 0 ] || [ "$prev_printed" != "$prev_name" ]; then
            echo "  DUPLICATE: $name" >> "$REPORT"
            echo "    Location 1: $prev_path" >> "$REPORT"
            prev_printed="$prev_name"
        fi
        echo "    Location 2: $path" >> "$REPORT"
        found_dupes=$((found_dupes + 1))
    else
        if [ "$prev_printed" = "$prev_name" ] && [ -n "$prev_name" ]; then
            echo "" >> "$REPORT"
        fi
    fi
    prev_name="$name"
    prev_path="$path"
done < "$temp_file"
rm "$temp_file"

echo "" >> "$REPORT"
echo "Total duplicate filename groups found: $found_dupes" >> "$REPORT"

# --- PASS 2: Find "copy" files (macOS creates these) ---
echo "" >> "$REPORT"
echo "=== FILES WITH 'COPY' IN THE NAME ===" >> "$REPORT"
echo "(These are often unintentional duplicates)" >> "$REPORT"
echo "" >> "$REPORT"

copy_count=0
for folder in "${FOLDERS[@]}"; do
    if [ -d "$folder" ]; then
        while IFS= read -r -d '' file; do
            echo "  $file" >> "$REPORT"
            copy_count=$((copy_count + 1))
        done < <(find "$folder" -maxdepth 4 -type f -iname "*copy*" -not -path "*/.*" -print0 2>/dev/null)
    fi
done
echo "" >> "$REPORT"
echo "Total 'copy' files found: $copy_count" >> "$REPORT"

# --- PASS 3: Find large files (potential waste) ---
echo "" >> "$REPORT"
echo "=== LARGE FILES OVER 500 MB ===" >> "$REPORT"
echo "(Review these — large files waste the most space)" >> "$REPORT"
echo "" >> "$REPORT"

for folder in "${FOLDERS[@]}"; do
    if [ -d "$folder" ]; then
        find "$folder" -maxdepth 4 -type f -size +500M -not -path "*/.*" -print0 2>/dev/null | while IFS= read -r -d '' file; do
            size=$(du -h "$file" 2>/dev/null | cut -f1)
            echo "  $size  $file" >> "$REPORT"
        done
    fi
done

# --- PASS 4: Find old Downloads (last opened > 60 days ago) ---
echo "" >> "$REPORT"
echo "=== DOWNLOADS NOT OPENED IN 60+ DAYS ===" >> "$REPORT"
echo "" >> "$REPORT"

old_count=0
find "$HOME/Downloads" -maxdepth 1 -type f -not -name ".DS_Store" -atime +60 -print0 2>/dev/null | while IFS= read -r -d '' file; do
    size=$(du -h "$file" 2>/dev/null | cut -f1)
    echo "  $size  $(basename "$file")" >> "$REPORT"
    old_count=$((old_count + 1))
done

echo "" >> "$REPORT"
echo "==========================================" >> "$REPORT"
echo "Report saved to: $REPORT" >> "$REPORT"

echo ""
echo "Done! Report saved to:"
echo "  $REPORT"
echo ""
echo "Open it with: open \"$REPORT\""

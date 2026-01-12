#!/usr/bin/env python3
"""
Automated cleanup script - runs without GUI
Can be scheduled via cron or launchd
"""
import os
import sys
from datetime import datetime
from pathlib import Path

# Add parent directory to path
sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))

from cleanup_engine import CleanupEngine, format_size
import config


def run_auto_cleanup():
    """Run automated cleanup and generate report"""
    engine = CleanupEngine()
    
    print("=" * 50)
    print(f"MacCleanup Auto Run - {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    print("=" * 50)
    
    # Check connections
    print(f"\n📁 Dropbox: {'Connected' if config.DROPBOX_ROOT.exists() else 'Not Found'}")
    print(f"💾 External SSD: {'Connected' if config.SSD_ROOT.exists() else 'Not Connected'}")
    
    # Get summary before cleanup
    print("\n--- Before Cleanup ---")
    summary = engine.get_summary()
    for loc in ['desktop', 'downloads', 'documents']:
        info = summary.get(loc, {})
        if info.get('exists'):
            print(f"  {loc.title()}: {info['total_size_mb']} MB, {info['file_count']} files")
    
    # Run cleanup
    print("\n🧹 Running cleanup...")
    report = engine.run_cleanup(dry_run=False)
    
    # Print results
    print("\n--- Cleanup Results ---")
    print(f"  ✓ Junk files deleted: {len(report.junk_deleted)}")
    print(f"  ✓ Files moved: {len(report.files_moved)}")
    print(f"  ✓ Files archived: {len(report.files_archived)}")
    print(f"  ✓ Space freed: {format_size(report.space_freed)}")
    
    if report.errors:
        print(f"\n⚠️ Errors: {len(report.errors)}")
        for err in report.errors[:5]:
            print(f"    - {err}")
    
    if report.large_files:
        print(f"\n📊 Large files to review ({len(report.large_files)}):")
        for f in report.large_files[:5]:
            print(f"    - {f['path']} ({f['size_mb']:.1f} MB)")
    
    if report.duplicates:
        print(f"\n📋 Potential duplicates found ({len(report.duplicates)}):")
        for d in report.duplicates[:5]:
            print(f"    - {d['duplicate']}")
    
    # Save report to file
    report_path = Path(config.HOME) / "Desktop" / f"MacCleanup_Report_{datetime.now().strftime('%Y%m%d_%H%M')}.txt"
    with open(report_path, 'w') as f:
        f.write(f"MacCleanup Report - {datetime.now()}\n")
        f.write("=" * 50 + "\n\n")
        f.write(f"Junk deleted: {len(report.junk_deleted)}\n")
        f.write(f"Files moved: {len(report.files_moved)}\n")
        f.write(f"Space freed: {format_size(report.space_freed)}\n")
        if report.junk_deleted:
            f.write("\nDeleted files:\n")
            for item in report.junk_deleted:
                f.write(f"  - {item}\n")
        if report.files_moved:
            f.write("\nMoved files:\n")
            for item in report.files_moved:
                f.write(f"  - {item['from']} -> {item['to']}\n")
    
    print(f"\n📄 Report saved to: {report_path}")
    print("\n" + "=" * 50)
    
    return report


if __name__ == "__main__":
    run_auto_cleanup()

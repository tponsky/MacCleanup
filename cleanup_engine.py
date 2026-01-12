"""Core cleanup engine for MacCleanup"""
import os
import shutil
import fnmatch
from pathlib import Path
from datetime import datetime, timedelta
from dataclasses import dataclass, field
from typing import Optional
import config
from file_renamer import FileRenamer


@dataclass
class FileInfo:
    """Information about a file"""
    path: Path
    name: str
    size: int
    modified: datetime
    category: str
    age_days: int
    suggested_action: str = ""
    suggested_destination: Optional[Path] = None
    description: str = ""  # Human-readable description
    is_latest_version: bool = False  # If this is the latest version in a set
    version_group: Optional[str] = None  # Group ID for versioned files
    needs_clarification: bool = False  # Whether user input is needed
    clarification_question: str = ""  # Question to ask user
    suggested_rename: Optional[str] = None  # Suggested new filename
    rename_reason: str = ""  # Why rename is suggested


@dataclass
class CleanupReport:
    """Report of cleanup actions"""
    timestamp: datetime = field(default_factory=datetime.now)
    junk_deleted: list = field(default_factory=list)
    files_moved: list = field(default_factory=list)
    files_archived: list = field(default_factory=list)
    large_files: list = field(default_factory=list)
    old_files: list = field(default_factory=list)
    duplicates: list = field(default_factory=list)
    space_freed: int = 0
    errors: list = field(default_factory=list)


class CleanupEngine:
    """Main cleanup engine"""
    
    def __init__(self):
        self.report = CleanupReport()
    
    def get_file_category(self, path: Path) -> str:
        """Determine category of a file based on extension"""
        ext = path.suffix.lower()
        for category, extensions in config.FILE_CATEGORIES.items():
            if ext in extensions:
                return category
        return "other"
    
    def is_junk_file(self, path: Path) -> bool:
        """Check if file matches junk patterns"""
        name = path.name
        for pattern in config.JUNK_PATTERNS:
            if fnmatch.fnmatch(name, pattern):
                return True
        return False
    
    def is_screenshot(self, path: Path) -> bool:
        """Check if file is a screenshot"""
        name = path.name
        for pattern in config.SCREENSHOT_PATTERNS:
            if fnmatch.fnmatch(name, pattern):
                return True
        return False
    
    def get_file_description(self, path: Path, category: str) -> str:
        """Get a human-readable description of what the file is"""
        name = path.name.lower()
        
        # Screenshots - extract date/time info
        if self.is_screenshot(path):
            # Try to extract date from filename
            import re
            date_match = re.search(r'(\d{4}-\d{2}-\d{2})', name)
            time_match = re.search(r'at\s+(\d+\.\d+\.\d+)', name)
            if date_match and time_match:
                return f"Screenshot from {date_match.group(1)} at {time_match.group(1)}"
            elif date_match:
                return f"Screenshot from {date_match.group(1)}"
            return "Screenshot"
        
        # Presentations
        if category == "presentations":
            # Remove common suffixes
            desc = path.stem
            desc = desc.replace(" [Autosaved]", "")
            desc = desc.replace(" (Autosaved)", "")
            desc = desc.replace("_", " ")
            if "deck" in desc.lower():
                return f"Presentation Deck: {desc}"
            if "pitch" in desc.lower():
                return f"Pitch Presentation: {desc}"
            if "workshop" in desc.lower():
                return f"Workshop Presentation: {desc}"
            return f"Presentation: {desc}"
        
        # Documents
        if category == "documents":
            desc = path.stem.replace("_", " ")
            if "script" in desc.lower():
                return f"Script/Notes: {desc}"
            if "resume" or "cv" in desc.lower():
                return f"Resume/CV: {desc}"
            return f"Document: {desc}"
        
        # Videos
        if category == "videos":
            desc = path.stem.replace("_", " ")
            if "demo" in desc.lower():
                return f"Demo Video: {desc}"
            if "recording" in desc.lower():
                return f"Screen Recording: {desc}"
            if "keynote" in desc.lower():
                return f"Keynote Video: {desc}"
            return f"Video: {desc}"
        
        # PDFs
        if category == "pdfs":
            desc = path.stem.replace("_", " ")
            if "report" in desc.lower():
                return f"Report: {desc}"
            if "brief" in desc.lower():
                return f"Brief: {desc}"
            return f"PDF Document: {desc}"
        
        # Images
        if category == "images":
            if "gemini" in name:
                return "AI Generated Image (Gemini)"
            if "screenshot" in name:
                return "Screenshot"
            return f"Image: {path.stem}"
        
        # Default
        return f"{category.title()}: {path.stem}"
    
    def get_file_age_days(self, path: Path) -> int:
        """Get file age in days"""
        mtime = datetime.fromtimestamp(path.stat().st_mtime)
        return (datetime.now() - mtime).days
    
    def scan_directory(self, directory: Path) -> list[FileInfo]:
        """Scan a directory and return file information"""
        files = []
        if not directory.exists():
            return files
        
        for item in directory.iterdir():
            if item.is_file() and not item.name.startswith('.'):
                try:
                    stat = item.stat()
                    category = self.get_file_category(item)
                    age_days = self.get_file_age_days(item)
                    
                    file_info = FileInfo(
                        path=item,
                        name=item.name,
                        size=stat.st_size,
                        modified=datetime.fromtimestamp(stat.st_mtime),
                        category=category,
                        age_days=age_days,
                        description=self.get_file_description(item, category),
                    )
                    
                    # Determine suggested action
                    file_info.suggested_action, file_info.suggested_destination = \
                        self.get_suggested_action(file_info)
                    
                    # Skip renaming - only rename if we can add meaningful context
                    # Since we can't analyze file content, renaming doesn't improve findability
                    # file_info.suggested_rename = None
                    
                    files.append(file_info)
                except (OSError, PermissionError):
                    pass
        
        return files
    
    def get_suggested_action(self, file_info: FileInfo) -> tuple[str, Optional[Path]]:
        """Get suggested action for a file"""
        path = file_info.path
        
        # Junk files - delete
        if self.is_junk_file(path):
            return "delete", None
        
        # Screenshots - archive if old
        if self.is_screenshot(path):
            if file_info.age_days > config.SCREENSHOT_MAX_AGE:
                return "archive", config.DROPBOX_FOLDERS["screenshots"] / "Archive"
            return "move", config.DROPBOX_FOLDERS["screenshots"]
        
        # Videos - move to SSD (but ask if SSD not connected)
        if file_info.category == "videos":
            if config.SSD_ROOT.exists():
                return "move_to_ssd", config.SSD_FOLDERS["videos"]
            # Need clarification - SSD not connected
            file_info.needs_clarification = True
            file_info.clarification_question = f"Large video file ({format_size(file_info.size)}). SSD not connected. Move to Dropbox or keep on laptop?"
            return "flag", None
        
        # Presentations - move to Dropbox
        if file_info.category == "presentations":
            return "move", config.DROPBOX_FOLDERS["presentations"]
        
        # PDFs - move to Dropbox
        if file_info.category == "pdfs":
            return "move", config.DROPBOX_FOLDERS["pdfs"]
        
        # Installers in Downloads - ask if really old
        if file_info.category == "installers" and "Downloads" in str(path):
            if file_info.age_days > 30:
                return "delete", None
            # Recent installer - might still need it
            file_info.needs_clarification = True
            file_info.clarification_question = f"Installer file ({file_info.age_days} days old). Delete or keep?"
            return "flag", None
        
        # Old files - flag
        if file_info.age_days > config.DOWNLOADS_MAX_AGE:
            return "archive", config.DROPBOX_FOLDERS["archive"]
        
        # Large files - flag
        if file_info.size > config.LARGE_FILE_THRESHOLD * 1024 * 1024:
            return "flag_large", None
        
        return "keep", None
    
    def find_duplicates(self, directory: Path) -> list[dict]:
        """Find files with duplicate patterns like (1), (2), copy
        Returns list of dicts with 'duplicate', 'original', 'is_latest', 'group_id'"""
        duplicates = []
        if not directory.exists():
            return duplicates
        
        # Group files by base name
        file_groups = {}
        
        files = list(directory.glob("*"))
        for f in files:
            if not f.is_file() or f.name.startswith('.'):
                continue
            
            name = f.stem
            base_name = name
            version_num = None
            is_copy = False
            
            # Check for (1), (2), etc.
            import re
            version_match = re.search(r' \((\d+)\)$', name)
            if version_match:
                base_name = name.rsplit(" (", 1)[0]
                version_num = int(version_match.group(1))
            
            # Check for "copy" suffix
            elif " copy" in name.lower():
                base_name = re.sub(r'\s+copy\s*$', '', name, flags=re.IGNORECASE)
                is_copy = True
                version_num = 999  # Copies are considered "older"
            
            # Create group key
            group_key = f"{base_name}{f.suffix}".lower()
            
            if group_key not in file_groups:
                file_groups[group_key] = []
            
            file_groups[group_key].append({
                'path': f,
                'name': f.name,
                'base_name': base_name,
                'version': version_num if version_num is not None else 0,
                'is_copy': is_copy,
                'modified': datetime.fromtimestamp(f.stat().st_mtime),
                'size': f.stat().st_size,
            })
        
        # Process groups to find duplicates and determine latest
        for group_key, group_files in file_groups.items():
            if len(group_files) <= 1:
                continue
            
            # Sort by version number (lower is better), then by modified date
            group_files.sort(key=lambda x: (x['version'], -x['modified'].timestamp()))
            
            # The first one (lowest version, most recent) is the latest
            latest = group_files[0]
            
            # Mark others as duplicates
            for f in group_files[1:]:
                duplicates.append({
                    'duplicate': str(f['path']),
                    'original': str(latest['path']),
                    'is_latest': False,
                    'group_id': group_key,
                    'duplicate_name': f['name'],
                    'original_name': latest['name'],
                    'duplicate_date': f['modified'].isoformat(),
                    'original_date': latest['modified'].isoformat(),
                    'duplicate_size': f['size'],
                    'original_size': latest['size'],
                })
            
            # Also mark the latest one
            if len(group_files) > 1:
                duplicates.append({
                    'duplicate': str(latest['path']),
                    'original': str(latest['path']),
                    'is_latest': True,
                    'group_id': group_key,
                    'duplicate_name': latest['name'],
                    'original_name': latest['name'],
                })
        
        return duplicates
    
    def delete_junk_files(self, directory: Path, dry_run: bool = True) -> list[Path]:
        """Delete junk/temp files"""
        deleted = []
        if not directory.exists():
            return deleted
        
        for pattern in config.JUNK_PATTERNS:
            for f in directory.rglob(pattern):
                if f.is_file():
                    if not dry_run:
                        try:
                            size = f.stat().st_size
                            f.unlink()
                            self.report.space_freed += size
                            self.report.junk_deleted.append(str(f))
                        except (OSError, PermissionError) as e:
                            self.report.errors.append(f"Could not delete {f}: {e}")
                    deleted.append(f)
        
        return deleted
    
    def move_file(self, source: Path, destination: Path, dry_run: bool = True, new_name: Optional[str] = None) -> bool:
        """Move a file to destination, optionally with a new name"""
        if not source.exists():
            return False
        
        try:
            destination.parent.mkdir(parents=True, exist_ok=True)
            
            # Use new name if provided, otherwise use original
            if new_name:
                final_dest = destination / new_name if destination.is_dir() else destination.parent / new_name
            else:
                final_dest = destination / source.name if destination.is_dir() else destination
            
            # Handle name conflicts
            if final_dest.exists() and final_dest != source:
                stem = final_dest.stem
                suffix = final_dest.suffix
                counter = 1
                while final_dest.exists():
                    final_dest = final_dest.parent / f"{stem}_{counter}{suffix}"
                    counter += 1
            
            if not dry_run:
                shutil.move(str(source), str(final_dest))
                self.report.files_moved.append({
                    "from": str(source),
                    "to": str(final_dest),
                    "renamed": new_name is not None
                })
            
            return True
        except (OSError, PermissionError) as e:
            self.report.errors.append(f"Could not move {source}: {e}")
            return False
    
    def rename_file(self, source: Path, new_name: str, dry_run: bool = True) -> bool:
        """Rename a file in place"""
        if not source.exists():
            return False
        
        try:
            new_path = source.parent / new_name
            
            # Handle name conflicts
            if new_path.exists() and new_path != source:
                stem = new_path.stem
                suffix = new_path.suffix
                counter = 1
                while new_path.exists():
                    new_path = new_path.parent / f"{stem}_{counter}{suffix}"
                    counter += 1
            
            if not dry_run:
                source.rename(new_path)
                self.report.files_moved.append({
                    "from": str(source),
                    "to": str(new_path),
                    "renamed": True
                })
            
            return True
        except (OSError, PermissionError) as e:
            self.report.errors.append(f"Could not rename {source}: {e}")
            return False
    
    def run_cleanup_selected(self, selected_action_ids: list) -> CleanupReport:
        """Run cleanup for selected actions only"""
        self.report = CleanupReport()
        
        # First, get all preview items
        all_items = []
        for name, directory in config.WATCHED_DIRS.items():
            if not directory.exists():
                continue
            
            # Get all files
            files = self.scan_directory(directory)
            for f in files:
                all_items.append({
                    'id': len(all_items),
                    'file_info': f,
                    'action': f.suggested_action,
                    'dest': f.suggested_destination,
                })
            
            # Get duplicates
            duplicates = self.find_duplicates(directory)
            for dup in duplicates:
                all_items.append({
                    'id': len(all_items),
                    'duplicate_info': dup,
                    'action': 'delete' if not dup.get('is_latest') else 'keep',
                })
        
        # Execute only selected actions
        for item in all_items:
            if str(item['id']) not in selected_action_ids:
                continue
            
            if 'file_info' in item:
                f = item['file_info']
                action = item['action']
                dest = item.get('dest')
                
                if action == "delete":
                    try:
                        size = f.path.stat().st_size
                        f.path.unlink()
                        self.report.space_freed += size
                        self.report.junk_deleted.append(str(f.path))
                    except (OSError, PermissionError) as e:
                        self.report.errors.append(f"Could not delete {f.path}: {e}")
                
                elif action in ["move", "move_to_ssd", "archive"] and dest:
                    # Use suggested rename if available
                    new_name = f.suggested_rename if f.suggested_rename else None
                    self.move_file(f.path, dest, dry_run=False, new_name=new_name)
            
            elif 'duplicate_info' in item:
                dup = item['duplicate_info']
                if not dup.get('is_latest'):
                    try:
                        dup_path = Path(dup['duplicate'])
                        size = dup_path.stat().st_size
                        dup_path.unlink()
                        self.report.space_freed += size
                        self.report.junk_deleted.append(dup['duplicate'])
                    except (OSError, PermissionError) as e:
                        self.report.errors.append(f"Could not delete {dup['duplicate']}: {e}")
        
        return self.report
    
    def run_cleanup(self, dry_run: bool = True) -> CleanupReport:
        """Run full cleanup process"""
        self.report = CleanupReport()
        
        # Clean each watched directory
        for name, directory in config.WATCHED_DIRS.items():
            if not directory.exists():
                continue
            
            # Delete junk files
            self.delete_junk_files(directory, dry_run)
            
            # Scan and process files
            files = self.scan_directory(directory)
            
            for file_info in files:
                action = file_info.suggested_action
                dest = file_info.suggested_destination
                
                if action == "delete":
                    if not dry_run:
                        try:
                            file_info.path.unlink()
                            self.report.space_freed += file_info.size
                            self.report.junk_deleted.append(str(file_info.path))
                        except (OSError, PermissionError) as e:
                            self.report.errors.append(str(e))
                
                elif action in ["move", "move_to_ssd", "archive"] and dest:
                    self.move_file(file_info.path, dest, dry_run)
                
                elif action == "flag_large":
                    self.report.large_files.append({
                        "path": str(file_info.path),
                        "size_mb": file_info.size / (1024 * 1024),
                    })
            
            # Find duplicates
            duplicates = self.find_duplicates(directory)
            for dup, original in duplicates:
                self.report.duplicates.append({
                    "duplicate": str(dup),
                    "original": str(original),
                })
        
        return self.report
    
    def get_summary(self) -> dict:
        """Get summary statistics"""
        summary = {
            "desktop": self._get_dir_summary(config.WATCHED_DIRS["desktop"]),
            "downloads": self._get_dir_summary(config.WATCHED_DIRS["downloads"]),
            "documents": self._get_dir_summary(config.WATCHED_DIRS["documents"]),
            "ssd_connected": config.SSD_ROOT.exists(),
            "dropbox_connected": config.DROPBOX_ROOT.exists(),
        }
        return summary
    
    def _get_dir_summary(self, directory: Path) -> dict:
        """Get summary for a directory"""
        if not directory.exists():
            return {"exists": False}
        
        total_size = 0
        file_count = 0
        category_counts = {}
        junk_count = 0
        
        for f in directory.iterdir():
            if f.is_file() and not f.name.startswith('.'):
                try:
                    total_size += f.stat().st_size
                    file_count += 1
                    
                    cat = self.get_file_category(f)
                    category_counts[cat] = category_counts.get(cat, 0) + 1
                    
                    if self.is_junk_file(f):
                        junk_count += 1
                except (OSError, PermissionError):
                    pass
        
        return {
            "exists": True,
            "total_size_mb": round(total_size / (1024 * 1024), 2),
            "file_count": file_count,
            "categories": category_counts,
            "junk_count": junk_count,
        }


def format_size(bytes_size: int) -> str:
    """Format bytes to human readable size"""
    for unit in ['B', 'KB', 'MB', 'GB', 'TB']:
        if bytes_size < 1024:
            return f"{bytes_size:.1f} {unit}"
        bytes_size /= 1024
    return f"{bytes_size:.1f} PB"

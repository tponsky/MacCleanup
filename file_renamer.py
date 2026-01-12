"""Lightweight file renaming suggestions based on content analysis"""
import re
from pathlib import Path
from datetime import datetime
from typing import Optional, Tuple


class FileRenamer:
    """Suggests better filenames based on file content and metadata"""
    
    @staticmethod
    def suggest_name(file_path: Path, category: str) -> Optional[Tuple[str, str]]:
        """
        Suggest a better filename
        Returns: (suggested_name, reason) or None if no suggestion
        """
        try:
            if category == "images":
                return FileRenamer._suggest_image_name(file_path)
            elif category == "presentations":
                return FileRenamer._suggest_presentation_name(file_path)
            elif category == "documents":
                return FileRenamer._suggest_document_name(file_path)
            elif category == "pdfs":
                return FileRenamer._suggest_pdf_name(file_path)
            elif category == "videos":
                return FileRenamer._suggest_video_name(file_path)
            else:
                return FileRenamer._suggest_generic_name(file_path)
        except Exception:
            # Fail silently - don't break cleanup if renaming fails
            return None
    
    @staticmethod
    def _suggest_image_name(path: Path) -> Optional[Tuple[str, str]]:
        """Suggest name for image files - skip screenshots, only rename if we can make it better"""
        name = path.stem
        ext = path.suffix
        
        # Screenshots - DON'T rename them unless we can add meaningful context
        # Since we can't analyze image content, screenshots keep their original names
        if "screenshot" in name.lower() or "screen shot" in name.lower():
            return None  # Skip renaming screenshots - we can't make them more descriptive
        
        # For other images, only suggest rename if filename is unclear
        # Skip generic names like IMG_1234, DSC_5678 - we can't make them better
        if re.match(r'^(IMG_|DSC_|Photo_|Image_)\d+$', name, re.IGNORECASE):
            return None  # Can't improve generic camera names without image analysis
        
        # Only suggest rename if we can actually improve it
        return None  # Skip image renaming unless we have meaningful content to add
    
    @staticmethod
    def _suggest_presentation_name(path: Path) -> Optional[Tuple[str, str]]:
        """Suggest name for presentation files - keep version markers, only clean up temp markers"""
        name = path.stem
        ext = path.suffix
        
        # Only remove temporary markers like [Autosaved], keep version numbers
        clean_name = name
        clean_name = re.sub(r'\s*\[Autosaved\]', '', clean_name, flags=re.IGNORECASE)
        clean_name = re.sub(r'\s*\(Autosaved\)', '', clean_name, flags=re.IGNORECASE)
        clean_name = clean_name.strip()
        
        # Only suggest rename if we removed temp markers
        # KEEP version numbers like (1), (2) - they're useful!
        if clean_name != name and len(clean_name) > 3:
            suggested = f"{clean_name}{ext}"
            return (suggested, "Removed temporary markers")
        
        # Don't rename presentations - names are usually good and version markers are useful
        return None
    
    @staticmethod
    def _suggest_document_name(path: Path) -> Optional[Tuple[str, str]]:
        """Suggest name for document files - keep version markers, they're useful"""
        # Don't rename documents - version markers like (1), (2), (3) are useful
        # They help identify which version is which
        return None
    
    @staticmethod
    def _suggest_pdf_name(path: Path) -> Optional[Tuple[str, str]]:
        """Suggest name for PDF files - keep version markers"""
        # Don't rename PDFs - version markers are useful information
        # They help identify which version is which
        return None
    
    @staticmethod
    def _suggest_video_name(path: Path) -> Optional[Tuple[str, str]]:
        """Suggest name for video files - skip screen recordings"""
        name = path.stem
        ext = path.suffix
        
        # Screen recordings - DON'T rename, we can't make them more descriptive
        if "screen recording" in name.lower() or "recording" in name.lower():
            return None  # Skip renaming - we can't add meaningful context
        
        # Skip generic camera video names too
        if re.match(r'^(IMG_|VID_|MOV_)\d+$', name, re.IGNORECASE):
            return None  # Can't improve without video analysis
        
        # Only rename if we can actually make it better
        return None  # Skip video renaming unless we have meaningful content
    
    @staticmethod
    def _suggest_generic_name(path: Path) -> Optional[Tuple[str, str]]:
        """Generic name cleanup - keep version markers"""
        # Don't rename - version markers like (1), (2), (3), "copy" are useful
        # They help identify which version is which
        return None

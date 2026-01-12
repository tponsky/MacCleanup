"""MacCleanup - Web-based file cleanup tool for macOS"""
import os
import json
from pathlib import Path
from datetime import datetime
from flask import Flask, render_template_string, jsonify, request
from cleanup_engine import CleanupEngine, format_size
import config

app = Flask(__name__)
engine = CleanupEngine()

# HTML Template with embedded CSS and JS
HTML_TEMPLATE = '''
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>MacCleanup</title>
    <link href="https://fonts.googleapis.com/css2?family=SF+Pro+Display:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg-primary: #1a1a2e;
            --bg-secondary: #16213e;
            --bg-card: #0f3460;
            --accent: #e94560;
            --accent-light: #ff6b6b;
            --success: #00d9a5;
            --warning: #ffc93c;
            --text-primary: #ffffff;
            --text-secondary: #a0a0b0;
            --border: rgba(255,255,255,0.1);
        }
        
        * {
            margin: 0;
            padding: 0;
            box-sizing: border-box;
        }
        
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'SF Pro Display', 'Segoe UI', sans-serif;
            background: linear-gradient(135deg, var(--bg-primary) 0%, var(--bg-secondary) 100%);
            min-height: 100vh;
            color: var(--text-primary);
            padding: 2rem;
        }
        
        .container {
            max-width: 1400px;
            margin: 0 auto;
        }
        
        header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 2rem;
            padding-bottom: 1rem;
            border-bottom: 1px solid var(--border);
        }
        
        h1 {
            font-size: 2.5rem;
            font-weight: 700;
            background: linear-gradient(135deg, var(--accent) 0%, var(--accent-light) 100%);
            -webkit-background-clip: text;
            -webkit-text-fill-color: transparent;
            display: flex;
            align-items: center;
            gap: 0.75rem;
        }
        
        h1::before {
            content: "🧹";
            -webkit-text-fill-color: initial;
        }
        
        .status-bar {
            display: flex;
            gap: 1rem;
            align-items: center;
        }
        
        .status-indicator {
            display: flex;
            align-items: center;
            gap: 0.5rem;
            padding: 0.5rem 1rem;
            background: var(--bg-card);
            border-radius: 2rem;
            font-size: 0.85rem;
        }
        
        .status-dot {
            width: 8px;
            height: 8px;
            border-radius: 50%;
            background: var(--success);
        }
        
        .status-dot.disconnected {
            background: var(--accent);
        }
        
        .grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 1.5rem;
            margin-bottom: 2rem;
        }
        
        .card {
            background: var(--bg-card);
            border-radius: 1rem;
            padding: 1.5rem;
            border: 1px solid var(--border);
            transition: transform 0.2s, box-shadow 0.2s;
        }
        
        .card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
        }
        
        .card-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }
        
        .card-title {
            font-size: 1.1rem;
            font-weight: 600;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .card-icon {
            font-size: 1.5rem;
        }
        
        .stat-value {
            font-size: 2rem;
            font-weight: 700;
            color: var(--accent-light);
        }
        
        .stat-label {
            color: var(--text-secondary);
            font-size: 0.85rem;
            margin-top: 0.25rem;
        }
        
        .category-list {
            margin-top: 1rem;
        }
        
        .category-item {
            display: flex;
            justify-content: space-between;
            padding: 0.5rem 0;
            border-bottom: 1px solid var(--border);
            font-size: 0.9rem;
        }
        
        .category-item:last-child {
            border-bottom: none;
        }
        
        .actions {
            display: flex;
            gap: 1rem;
            flex-wrap: wrap;
            margin-bottom: 2rem;
        }
        
        .btn {
            padding: 1rem 2rem;
            border: none;
            border-radius: 0.75rem;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.2s;
            display: flex;
            align-items: center;
            gap: 0.5rem;
        }
        
        .btn-primary {
            background: linear-gradient(135deg, var(--accent) 0%, var(--accent-light) 100%);
            color: white;
        }
        
        .btn-primary:hover {
            transform: scale(1.02);
            box-shadow: 0 5px 20px rgba(233, 69, 96, 0.4);
        }
        
        .btn-secondary {
            background: var(--bg-card);
            color: var(--text-primary);
            border: 1px solid var(--border);
        }
        
        .btn-secondary:hover {
            background: var(--bg-secondary);
        }
        
        .btn-success {
            background: linear-gradient(135deg, #00b894 0%, var(--success) 100%);
            color: white;
        }
        
        .btn:disabled {
            opacity: 0.5;
            cursor: not-allowed;
        }
        
        .results-panel {
            background: var(--bg-card);
            border-radius: 1rem;
            padding: 1.5rem;
            border: 1px solid var(--border);
            margin-top: 2rem;
        }
        
        .results-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 1rem;
        }
        
        .results-title {
            font-size: 1.25rem;
            font-weight: 600;
        }
        
        .file-list {
            max-height: 400px;
            overflow-y: auto;
        }
        
        .file-item {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 0.75rem 1rem;
            background: var(--bg-secondary);
            border-radius: 0.5rem;
            margin-bottom: 0.5rem;
            gap: 1rem;
        }
        
        .file-item.selected {
            border: 2px solid var(--accent);
        }
        
        .file-item.latest-version {
            border-left: 4px solid var(--success);
        }
        
        .file-checkbox {
            width: 20px;
            height: 20px;
            min-width: 20px;
            cursor: pointer;
            accent-color: var(--accent);
            flex-shrink: 0;
            margin-right: 0.75rem;
        }
        
        .version-badge {
            display: inline-block;
            padding: 0.25rem 0.5rem;
            background: var(--success);
            color: var(--bg-primary);
            border-radius: 0.25rem;
            font-size: 0.7rem;
            font-weight: 600;
            margin-left: 0.5rem;
        }
        
        .duplicate-badge {
            display: inline-block;
            padding: 0.25rem 0.5rem;
            background: var(--warning);
            color: var(--bg-primary);
            border-radius: 0.25rem;
            font-size: 0.7rem;
            font-weight: 600;
            margin-left: 0.5rem;
        }
        
        .file-info {
            flex: 1;
        }
        
        .file-name {
            font-weight: 500;
            margin-bottom: 0.25rem;
            word-break: break-all;
        }
        
        .file-meta {
            font-size: 0.8rem;
            color: var(--text-secondary);
        }
        
        .file-action {
            padding: 0.5rem 1rem;
            border-radius: 0.5rem;
            font-size: 0.8rem;
            font-weight: 600;
        }
        
        .action-delete {
            background: rgba(233, 69, 96, 0.2);
            color: var(--accent);
        }
        
        .action-move {
            background: rgba(0, 217, 165, 0.2);
            color: var(--success);
        }
        
        .action-archive {
            background: rgba(255, 201, 60, 0.2);
            color: var(--warning);
        }
        
        .summary-box {
            background: linear-gradient(135deg, var(--bg-secondary) 0%, var(--bg-card) 100%);
            border-radius: 1rem;
            padding: 2rem;
            margin-top: 1rem;
            text-align: center;
        }
        
        .summary-title {
            font-size: 1.5rem;
            margin-bottom: 1rem;
        }
        
        .summary-stats {
            display: flex;
            justify-content: center;
            gap: 3rem;
            flex-wrap: wrap;
        }
        
        .summary-stat {
            text-align: center;
        }
        
        .summary-stat-value {
            font-size: 2.5rem;
            font-weight: 700;
            color: var(--success);
        }
        
        .summary-stat-label {
            color: var(--text-secondary);
            font-size: 0.9rem;
        }
        
        .loading {
            display: none;
            text-align: center;
            padding: 2rem;
        }
        
        .loading.active {
            display: block;
        }
        
        .spinner {
            width: 40px;
            height: 40px;
            border: 3px solid var(--border);
            border-top-color: var(--accent);
            border-radius: 50%;
            animation: spin 1s linear infinite;
            margin: 0 auto 1rem;
        }
        
        @keyframes spin {
            to { transform: rotate(360deg); }
        }
        
        .toast {
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            background: var(--bg-card);
            padding: 1rem 1.5rem;
            border-radius: 0.75rem;
            border: 1px solid var(--border);
            box-shadow: 0 10px 40px rgba(0,0,0,0.3);
            transform: translateY(100px);
            opacity: 0;
            transition: all 0.3s;
        }
        
        .toast.show {
            transform: translateY(0);
            opacity: 1;
        }
        
        .toast.success {
            border-color: var(--success);
        }
        
        .toast.error {
            border-color: var(--accent);
        }
        
        footer {
            text-align: center;
            margin-top: 3rem;
            padding-top: 2rem;
            border-top: 1px solid var(--border);
            color: var(--text-secondary);
            font-size: 0.85rem;
        }
    </style>
</head>
<body>
    <div class="container">
        <header>
            <h1>MacCleanup</h1>
            <div class="status-bar">
                <div class="status-indicator">
                    <div class="status-dot" id="dropbox-status"></div>
                    <span>Dropbox</span>
                </div>
                <div class="status-indicator">
                    <div class="status-dot" id="ssd-status"></div>
                    <span>External SSD</span>
                </div>
            </div>
        </header>
        
        <div class="grid" id="summary-grid">
            <!-- Cards will be populated by JS -->
        </div>
        
        <div class="actions">
            <button class="btn btn-secondary" onclick="scanFiles()">
                🔍 Scan Files
            </button>
            <button class="btn btn-primary" onclick="previewCleanup()">
                👀 Preview Cleanup
            </button>
            <button class="btn btn-success" onclick="runCleanup()" id="run-btn">
                ✨ Run Cleanup
            </button>
        </div>
        
        <div class="loading" id="loading">
            <div class="spinner"></div>
            <p>Analyzing your files...</p>
        </div>
        
        <div class="results-panel" id="results" style="display: none;">
            <div class="results-header">
                <h2 class="results-title">Cleanup Preview</h2>
                <div style="display: flex; gap: 1rem; align-items: center;">
                    <span id="results-count"></span>
                    <button class="btn btn-secondary" onclick="selectAllActions()" style="padding: 0.5rem 1rem; font-size: 0.85rem;">
                        ✓ Select All
                    </button>
                    <button class="btn btn-secondary" onclick="deselectAllActions()" style="padding: 0.5rem 1rem; font-size: 0.85rem;">
                        ✗ Deselect All
                    </button>
                </div>
            </div>
            <div class="file-list" id="file-list">
                <!-- Files will be listed here -->
            </div>
            <div id="clarification-panel" style="display: none; margin-top: 1.5rem; padding: 1.5rem; background: var(--bg-secondary); border-radius: 0.75rem; border: 1px solid var(--border;">
                <h3 style="margin-bottom: 1rem; color: var(--warning);">❓ Need Your Input</h3>
                <div id="clarification-questions"></div>
            </div>
        </div>
        
        <div class="summary-box" id="summary-box" style="display: none;">
            <h2 class="summary-title">🎉 Cleanup Complete!</h2>
            <div class="summary-stats">
                <div class="summary-stat">
                    <div class="summary-stat-value" id="files-cleaned">0</div>
                    <div class="summary-stat-label">Files Cleaned</div>
                </div>
                <div class="summary-stat">
                    <div class="summary-stat-value" id="space-freed">0 MB</div>
                    <div class="summary-stat-label">Space Freed</div>
                </div>
                <div class="summary-stat">
                    <div class="summary-stat-value" id="files-moved">0</div>
                    <div class="summary-stat-label">Files Organized</div>
                </div>
            </div>
        </div>
        
        <footer>
            <p>MacCleanup v1.0 • Made for Todd's MacBook</p>
            <p style="margin-top: 0.5rem;">Run periodically to keep your files organized</p>
        </footer>
    </div>
    
    <div class="toast" id="toast"></div>
    
    <script>
        // Load summary on page load
        document.addEventListener('DOMContentLoaded', loadSummary);
        
        async function loadSummary() {
            try {
                const response = await fetch('/api/summary');
                const data = await response.json();
                renderSummary(data);
                updateStatus(data);
            } catch (error) {
                showToast('Failed to load summary', 'error');
            }
        }
        
        function renderSummary(data) {
            const grid = document.getElementById('summary-grid');
            const dirs = ['desktop', 'downloads', 'documents'];
            const icons = { desktop: '🖥️', downloads: '📥', documents: '📄' };
            const names = { desktop: 'Desktop', downloads: 'Downloads', documents: 'Documents' };
            
            let html = '';
            for (const dir of dirs) {
                const info = data[dir];
                if (!info || !info.exists) continue;
                
                html += `
                    <div class="card">
                        <div class="card-header">
                            <div class="card-title">
                                <span class="card-icon">${icons[dir]}</span>
                                ${names[dir]}
                            </div>
                        </div>
                        <div class="stat-value">${info.total_size_mb} MB</div>
                        <div class="stat-label">${info.file_count} files</div>
                        <div class="category-list">
                            ${Object.entries(info.categories || {}).map(([cat, count]) => `
                                <div class="category-item">
                                    <span>${cat}</span>
                                    <span>${count}</span>
                                </div>
                            `).join('')}
                        </div>
                        ${info.junk_count > 0 ? `
                            <div style="margin-top: 1rem; color: var(--warning);">
                                ⚠️ ${info.junk_count} junk files found
                            </div>
                        ` : ''}
                    </div>
                `;
            }
            grid.innerHTML = html;
        }
        
        function updateStatus(data) {
            document.getElementById('dropbox-status').className = 
                'status-dot' + (data.dropbox_connected ? '' : ' disconnected');
            document.getElementById('ssd-status').className = 
                'status-dot' + (data.ssd_connected ? '' : ' disconnected');
        }
        
        async function scanFiles() {
            showLoading(true);
            try {
                const response = await fetch('/api/scan');
                const data = await response.json();
                renderFileList(data.files, 'Scanned Files');
                showToast(`Found ${data.files.length} files to review`, 'success');
            } catch (error) {
                showToast('Scan failed', 'error');
            }
            showLoading(false);
        }
        
        async function previewCleanup() {
            showLoading(true);
            try {
                const response = await fetch('/api/preview');
                const data = await response.json();
                renderPreview(data);
                showToast('Preview ready - select actions to apply', 'success');
            } catch (error) {
                showToast('Preview failed', 'error');
            }
            showLoading(false);
        }
        
        async function runCleanup() {
            // Get selected actions
            const selectedActions = getSelectedActions();
            if (selectedActions.length === 0) {
                showToast('Please select at least one action', 'error');
                return;
            }
            
            if (!confirm(`This will apply ${selectedActions.length} selected actions. Continue?`)) return;
            
            showLoading(true);
            document.getElementById('summary-box').style.display = 'none';
            
            try {
                const response = await fetch('/api/cleanup', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({ selected_actions: selectedActions })
                });
                const data = await response.json();
                renderCleanupSummary(data);
                loadSummary(); // Refresh the summary
                showToast('Cleanup complete!', 'success');
                document.getElementById('results').style.display = 'none';
            } catch (error) {
                showToast('Cleanup failed', 'error');
            }
            showLoading(false);
        }
        
        function getSelectedActions() {
            const checkboxes = document.querySelectorAll('.file-checkbox:checked');
            return Array.from(checkboxes).map(cb => cb.dataset.actionId);
        }
        
        function selectAllActions() {
            document.querySelectorAll('.file-checkbox').forEach(cb => cb.checked = true);
            updateSelectedCount();
        }
        
        function deselectAllActions() {
            document.querySelectorAll('.file-checkbox').forEach(cb => cb.checked = false);
            updateSelectedCount();
        }
        
        function updateSelectedCount() {
            const count = document.querySelectorAll('.file-checkbox:checked').length;
            const total = document.querySelectorAll('.file-checkbox').length;
            const countEl = document.getElementById('results-count');
            if (countEl) {
                countEl.textContent = `${count} of ${total} selected`;
            }
        }
        
        function toggleItemSelection(checkbox) {
            const item = checkbox.closest('.file-item');
            if (checkbox.checked) {
                item.classList.add('selected');
            } else {
                item.classList.remove('selected');
            }
        }
        
        function renderFileList(files, title) {
            const results = document.getElementById('results');
            const fileList = document.getElementById('file-list');
            const count = document.getElementById('results-count');
            
            results.style.display = 'block';
            count.textContent = `${files.length} files`;
            
            fileList.innerHTML = files.map(f => `
                <div class="file-item">
                    <div class="file-info">
                        <div class="file-name">${f.name}</div>
                        <div class="file-meta">
                            ${f.category} • ${formatSize(f.size)} • ${f.age_days} days old
                        </div>
                    </div>
                    <span class="file-action action-${f.suggested_action}">
                        ${f.suggested_action}
                    </span>
                </div>
            `).join('');
        }
        
        function renderPreview(data) {
            const results = document.getElementById('results');
            const fileList = document.getElementById('file-list');
            const count = document.getElementById('results-count');
            
            results.style.display = 'block';
            
            let items = [];
            let actionId = 0;
            
            // Junk to delete
            data.junk.forEach(f => {
                const fileName = f.split('/').pop();
                let desc = fileName;
                if (fileName.startsWith('~$')) {
                    desc = `Office temporary file: ${fileName.replace('~$', '')}`;
                } else if (fileName === '.DS_Store') {
                    desc = 'macOS system file';
                }
                items.push({
                    id: actionId++,
                    name: fileName,
                    path: f,
                    action: 'delete',
                    type: 'Junk file',
                    description: desc,
                    is_latest: false
                });
            });
            
            // Files to move
            data.to_move.forEach(f => {
                items.push({
                    id: actionId++,
                    name: f.name,
                    path: f.path,
                    action: f.suggested_action || 'move',
                    type: f.category || 'file',
                    dest: f.suggested_destination,
                    description: f.description || f.name,
                    is_latest: f.is_latest_version || false,
                    size: f.size,
                    age_days: f.age_days,
                    suggested_rename: f.suggested_rename,
                    rename_reason: f.rename_reason
                });
            });
            
            // Duplicates - group them
            const duplicateGroups = {};
            data.duplicates.forEach(d => {
                const groupId = d.group_id || 'default';
                if (!duplicateGroups[groupId]) {
                    duplicateGroups[groupId] = [];
                }
                duplicateGroups[groupId].push(d);
            });
            
            Object.values(duplicateGroups).forEach(group => {
                group.forEach(d => {
                    items.push({
                        id: actionId++,
                        name: d.duplicate_name || d.duplicate.split('/').pop(),
                        path: d.duplicate,
                        action: d.is_latest ? 'keep' : 'delete',
                        type: 'Duplicate',
                        description: d.duplicate_name || d.duplicate.split('/').pop(),
                        is_latest: d.is_latest || false,
                        original: d.original_name || d.original.split('/').pop(),
                        group_id: d.group_id,
                        duplicate_date: d.duplicate_date,
                        original_date: d.original_date,
                        duplicate_size: d.duplicate_size,
                        original_size: d.original_size
                    });
                });
            });
            
            // Sort: latest versions first, then by action type
            items.sort((a, b) => {
                if (a.is_latest !== b.is_latest) return b.is_latest - a.is_latest;
                if (a.action !== b.action) return a.action.localeCompare(b.action);
                return a.name.localeCompare(b.name);
            });
            
            updateSelectedCount();
            
            fileList.innerHTML = items.map(item => {
                const actionClass = item.action === 'delete' ? 'action-delete' : 
                                   item.action === 'move' || item.action === 'move_to_ssd' ? 'action-move' : 
                                   item.action === 'archive' ? 'action-archive' : 'action-keep';
                const itemClass = item.is_latest ? 'file-item latest-version' : 'file-item';
                const badge = item.is_latest ? '<span class="version-badge">LATEST</span>' : 
                             item.type === 'Duplicate' ? '<span class="duplicate-badge">DUPLICATE</span>' : '';
                
                let meta = item.description || item.name;
                if (item.dest) {
                    const destName = item.dest.split('/').pop();
                    meta += ` → ${destName}`;
                }
                if (item.original && item.original !== item.name) {
                    meta += ` (original: ${item.original})`;
                }
                if (item.duplicate_date && item.original_date) {
                    const dupDate = new Date(item.duplicate_date).toLocaleDateString();
                    const origDate = new Date(item.original_date).toLocaleDateString();
                    meta += ` | Duplicate: ${dupDate}, Original: ${origDate}`;
                }
                if (item.size) {
                    meta += ` | ${formatSize(item.size)}`;
                }
                if (item.age_days !== undefined) {
                    meta += ` | ${item.age_days} days old`;
                }
                if (item.suggested_rename) {
                    meta += ` | 💡 Rename to: "${item.suggested_rename}" (${item.rename_reason})`;
                }
                
                return `
                    <div class="${itemClass}" data-action-id="${item.id}">
                        <input type="checkbox" class="file-checkbox" data-action-id="${item.id}" 
                               checked onchange="updateSelectedCount(); toggleItemSelection(this)" 
                               style="min-width: 20px; width: 20px; height: 20px; cursor: pointer;">
                        <div class="file-info" style="flex: 1; min-width: 0;">
                            <div class="file-name">
                                ${item.name}${badge}
                            </div>
                            <div class="file-meta">${meta}</div>
                        </div>
                        <span class="file-action ${actionClass}">${item.action}</span>
                    </div>
                `;
            }).join('') || '<p style="padding: 1rem; color: var(--text-secondary);">No cleanup actions needed!</p>';
            
            // Add event listeners for checkboxes
            document.querySelectorAll('.file-checkbox').forEach(cb => {
                cb.addEventListener('change', () => {
                    const item = cb.closest('.file-item');
                    if (cb.checked) {
                        item.classList.add('selected');
                    } else {
                        item.classList.remove('selected');
                    }
                    updateSelectedCount();
                });
            });
        }
        
        function renderCleanupSummary(data) {
            const box = document.getElementById('summary-box');
            box.style.display = 'block';
            
            document.getElementById('files-cleaned').textContent = data.junk_deleted.length;
            document.getElementById('space-freed').textContent = formatSize(data.space_freed);
            document.getElementById('files-moved').textContent = data.files_moved.length;
            
            document.getElementById('results').style.display = 'none';
        }
        
        function formatSize(bytes) {
            if (bytes < 1024) return bytes + ' B';
            if (bytes < 1024 * 1024) return (bytes / 1024).toFixed(1) + ' KB';
            if (bytes < 1024 * 1024 * 1024) return (bytes / (1024 * 1024)).toFixed(1) + ' MB';
            return (bytes / (1024 * 1024 * 1024)).toFixed(1) + ' GB';
        }
        
        function showLoading(show) {
            document.getElementById('loading').className = 'loading' + (show ? ' active' : '');
        }
        
        function showToast(message, type) {
            const toast = document.getElementById('toast');
            toast.textContent = message;
            toast.className = 'toast show ' + type;
            setTimeout(() => toast.className = 'toast', 3000);
        }
    </script>
</body>
</html>
'''


@app.route('/')
def index():
    return render_template_string(HTML_TEMPLATE)


@app.route('/api/summary')
def api_summary():
    return jsonify(engine.get_summary())


@app.route('/api/scan')
def api_scan():
    files = []
    for name, directory in config.WATCHED_DIRS.items():
        for f in engine.scan_directory(directory):
            files.append({
                "name": f.name,
                "path": str(f.path),
                "size": f.size,
                "category": f.category,
                "age_days": f.age_days,
                "suggested_action": f.suggested_action,
            })
    return jsonify({"files": files})


@app.route('/api/preview')
def api_preview():
    result = {
        "junk": [],
        "to_move": [],
        "duplicates": [],
        "large_files": [],
        "clarifications": [],
    }
    
    for name, directory in config.WATCHED_DIRS.items():
        # Find junk
        junk = engine.delete_junk_files(directory, dry_run=True)
        result["junk"].extend([str(f) for f in junk])
        
        # Find files to move
        for f in engine.scan_directory(directory):
            if f.suggested_action in ["move", "move_to_ssd", "archive", "delete"]:
                result["to_move"].append({
                    "name": f.name,
                    "path": str(f.path),
                    "category": f.category,
                    "description": f.description,
                    "suggested_action": f.suggested_action,
                    "suggested_destination": str(f.suggested_destination) if f.suggested_destination else None,
                    "is_latest_version": f.is_latest_version,
                    "size": f.size,
                    "age_days": f.age_days,
                    "suggested_rename": f.suggested_rename,
                    "rename_reason": f.rename_reason,
                })
        
        # Find duplicates with version info
        duplicates = engine.find_duplicates(directory)
        result["duplicates"].extend(duplicates)
        
        # Find large files
        for f in engine.scan_directory(directory):
            if f.size > config.LARGE_FILE_THRESHOLD * 1024 * 1024:
                result["large_files"].append({
                    "name": f.name,
                    "path": str(f.path),
                    "size_mb": f.size / (1024 * 1024),
                    "description": f.description,
                })
    
    return jsonify(result)


@app.route('/api/cleanup', methods=['POST'])
def api_cleanup():
    data = request.get_json() or {}
    selected_actions = data.get('selected_actions', [])
    
    # If no selections, run all (backward compatible)
    if not selected_actions:
        report = engine.run_cleanup(dry_run=False)
    else:
        # Run cleanup with selected actions only
        report = engine.run_cleanup_selected(selected_actions)
    
    return jsonify({
        "junk_deleted": report.junk_deleted,
        "files_moved": report.files_moved,
        "files_archived": report.files_archived,
        "space_freed": report.space_freed,
        "errors": report.errors,
    })


if __name__ == '__main__':
    # Check if first run - suggest running setup wizard
    USER_CONFIG_FILE = Path(__file__).parent / "user_config.json"
    if not USER_CONFIG_FILE.exists():
        print("⚠️  First time setup recommended!")
        print("   Run: python3 setup_wizard.py")
        print("   Or edit config.py to customize paths")
        print()
    
    print("🧹 MacCleanup is running!")
    print("   Open http://localhost:5050 in your browser")
    print("   Press Ctrl+C to stop")
    app.run(host='127.0.0.1', port=5050, debug=False)

<?php
header('Cache-Control: no-cache, no-store, must-revalidate');
header('Pragma: no-cache');
header('Expires: 0');
?><!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Repair Tracker Dashboard</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body { font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background: #f9fafb; color: #111827; }

        /* Header */
        .header { background: #fff; border-bottom: 1px solid #e5e7eb; position: sticky; top: 0; z-index: 10; }
        .header-inner { max-width: 1280px; margin: 0 auto; padding: 1.5rem 1rem; display: flex; align-items: center; justify-content: space-between; }
        .header h1 { font-size: 1.5rem; font-weight: 700; }
        .header p { font-size: 0.875rem; color: #6b7280; margin-top: 0.25rem; }
        .btn { display: inline-flex; align-items: center; gap: 0.5rem; padding: 0.5rem 1rem; font-size: 0.875rem; font-weight: 500; border-radius: 0.75rem; border: none; cursor: pointer; transition: all 0.15s; }
        .btn-secondary { background: #f3f4f6; color: #4b5563; }
        .btn-secondary:hover { background: #e5e7eb; }
        .btn-back { background: none; padding: 0.5rem; border-radius: 0.75rem; border: none; cursor: pointer; font-size: 1rem; }
        .btn-back:hover { background: #f3f4f6; }

        /* Main */
        .main { max-width: 1280px; margin: 0 auto; padding: 2rem 1rem; }

        /* Summary Cards */
        .summary-grid { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1rem; margin-bottom: 2rem; }
        @media (max-width: 768px) { .summary-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 480px) { .summary-grid { grid-template-columns: 1fr; } }
        .summary-card { background: #fff; border-radius: 1rem; border: 1px solid #f3f4f6; padding: 1.25rem; box-shadow: 0 1px 2px rgba(0,0,0,0.04); }
        .summary-card .label { font-size: 0.875rem; color: #6b7280; margin-bottom: 0.25rem; }
        .summary-card .value { font-size: 1.875rem; font-weight: 700; }
        .text-green { color: #16a34a; }
        .text-blue { color: #2563eb; }
        .text-gray { color: #4b5563; }

        /* Filter Tabs */
        .filter-tabs { display: flex; gap: 0.5rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
        .filter-tab { padding: 0.5rem 1rem; border-radius: 0.75rem; font-size: 0.875rem; font-weight: 500; border: 1px solid #e5e7eb; background: #fff; color: #4b5563; cursor: pointer; transition: all 0.15s; }
        .filter-tab:hover { background: #f3f4f6; }
        .filter-tab.active { background: #111827; color: #fff; border-color: #111827; }

        /* Project Cards */
        .projects-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; }
        @media (max-width: 1024px) { .projects-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 640px) { .projects-grid { grid-template-columns: 1fr; } }
        .project-card { background: #fff; border-radius: 1rem; border: 1px solid #f3f4f6; padding: 1.5rem; box-shadow: 0 1px 2px rgba(0,0,0,0.04); cursor: pointer; transition: all 0.2s; }
        .project-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); border-color: #d1d5db; }
        .project-card-header { display: flex; align-items: flex-start; justify-content: space-between; margin-bottom: 1rem; }
        .project-icon { padding: 0.5rem; background: #eff6ff; color: #2563eb; border-radius: 0.75rem; display: flex; align-items: center; justify-content: center; }
        .project-info { display: flex; align-items: center; gap: 0.75rem; }
        .project-name { font-weight: 600; font-size: 1.125rem; }
        .project-location { font-size: 0.875rem; color: #6b7280; display: flex; align-items: center; gap: 0.25rem; margin-top: 0.125rem; }
        .badge { display: inline-flex; align-items: center; padding: 0.25rem 0.625rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 500; background: #f3f4f6; color: #4b5563; }

        /* Progress */
        .progress-section { margin-bottom: 1rem; }
        .progress-header { display: flex; justify-content: space-between; align-items: flex-end; margin-bottom: 0.5rem; }
        .progress-text { font-size: 0.875rem; color: #6b7280; }
        .progress-pct { font-size: 1.5rem; font-weight: 700; }
        .progress-bar { width: 100%; background: #f3f4f6; border-radius: 9999px; height: 0.625rem; overflow: hidden; }
        .progress-fill { height: 100%; border-radius: 9999px; transition: width 0.5s ease; }
        .progress-bar-lg { height: 1rem; }
        .bg-green { background: #22c55e; }
        .bg-blue { background: #3b82f6; }
        .bg-gray-fill { background: #9ca3af; }
        .bg-orange { background: #f97316; }

        /* Stats */
        .stats-row { display: flex; align-items: center; gap: 1rem; font-size: 0.875rem; color: #6b7280; }
        .stat-dot { width: 0.5rem; height: 0.5rem; border-radius: 9999px; display: inline-block; }
        .stat-item { display: flex; align-items: center; gap: 0.25rem; }

        /* Detail Header */
        .detail-header { display: flex; align-items: center; gap: 1rem; }
        .detail-title { flex: 1; }
        .detail-progress { text-align: right; }
        .detail-progress .pct { font-size: 1.875rem; font-weight: 700; }
        .detail-progress .sub { font-size: 0.75rem; color: #6b7280; }

        /* Overall Card */
        .overall-card { background: #fff; border-radius: 1rem; border: 1px solid #f3f4f6; padding: 1.5rem; margin-bottom: 2rem; box-shadow: 0 1px 2px rgba(0,0,0,0.04); }
        .overall-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 0.75rem; }
        .status-legend { display: flex; gap: 1.5rem; margin-top: 1rem; flex-wrap: wrap; }
        .legend-item { display: flex; align-items: center; gap: 0.5rem; font-size: 0.875rem; color: #4b5563; }
        .legend-dot { width: 0.75rem; height: 0.75rem; border-radius: 0.125rem; }

        /* Wall Cards */
        .walls-grid { display: grid; grid-template-columns: repeat(3, 1fr); gap: 1.5rem; margin-bottom: 2rem; }
        @media (max-width: 1024px) { .walls-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 640px) { .walls-grid { grid-template-columns: 1fr; } }
        .wall-card { background: #fff; border-radius: 1rem; border: 1px solid #f3f4f6; padding: 1.25rem; box-shadow: 0 1px 2px rgba(0,0,0,0.04); cursor: pointer; transition: all 0.2s; }
        .wall-card:hover { box-shadow: 0 4px 12px rgba(0,0,0,0.08); border-color: #d1d5db; }
        .wall-header { display: flex; align-items: center; justify-content: space-between; margin-bottom: 1rem; }
        .wall-name { font-weight: 600; }
        .wall-pct { font-size: 1.125rem; font-weight: 700; }

        /* Circular Progress */
        .circle-wrap { display: flex; justify-content: center; margin-bottom: 1rem; }
        .circle-container { position: relative; width: 96px; height: 96px; }
        .circle-container svg { width: 96px; height: 96px; transform: rotate(-90deg); }
        .circle-label { position: absolute; inset: 0; display: flex; align-items: center; justify-content: center; font-size: 0.875rem; font-weight: 700; color: #374151; }

        /* Status Grid */
        .status-grid { display: grid; grid-template-columns: 1fr 1fr; gap: 0.5rem; font-size: 0.875rem; }
        .status-item { display: flex; align-items: center; gap: 0.5rem; color: #4b5563; }
        .status-dot { width: 0.75rem; height: 0.75rem; border-radius: 0.125rem; flex-shrink: 0; }
        .dot-green { background: #22c55e; }
        .dot-blue { background: #3b82f6; }
        .dot-orange { background: #f97316; }
        .dot-gray { background: #d1d5db; }
        .dot-purple { background: #a855f7; }
        .dot-pink { background: #ec4899; }

        /* Heatmap (project detail) */
        .heatmap { margin-top: 1rem; padding-top: 1rem; border-top: 1px solid #f3f4f6; }
        .heatmap-label { font-size: 0.75rem; color: #9ca3af; margin-bottom: 0.5rem; }
        .heatmap-grid { display: flex; flex-wrap: wrap; gap: 2px; }
        .heatmap-cell { width: 10px; height: 10px; border-radius: 2px; }
        .cell-green { background: #22c55e; }
        .cell-blue { background: #3b82f6; }
        .cell-orange { background: #f97316; }
        .cell-gray { background: #d1d5db; }
        .cell-purple { background: #a855f7; }
        .cell-pink { background: #ec4899; }

        /* Bay Grid (wall detail) */
        .bay-section { background: #fff; border-radius: 1rem; border: 1px solid #f3f4f6; padding: 1.25rem; margin-bottom: 1rem; box-shadow: 0 1px 2px rgba(0,0,0,0.04); }
        .bay-title { font-weight: 600; font-size: 1rem; margin-bottom: 0.75rem; color: #111827; }
        .bay-grid { display: grid; gap: 4px; }
        .bay-grid-header { display: contents; }
        .bay-col-label { text-align: center; font-size: 0.75rem; font-weight: 700; color: #6b7280; padding: 4px 0; }
        .bay-row-label { display: flex; align-items: center; justify-content: center; font-size: 0.75rem; font-weight: 600; color: #9ca3af; }
        .loc-cell { display: flex; align-items: center; justify-content: center; height: 36px; border-radius: 6px; font-size: 0.7rem; font-weight: 600; color: #fff; cursor: default; transition: transform 0.1s; position: relative; }
        .loc-cell:hover { transform: scale(1.08); z-index: 1; }
        .loc-cell.status-installed { background: #22c55e; }
        .loc-cell.status-drilled { background: #3b82f6; }
        .loc-cell.status-rebar { background: #f97316; }
        .loc-cell.status-notcomplete { background: #e5e7eb; color: #9ca3af; }
        .loc-cell.status-hss { background: #a855f7; }
        .loc-cell.status-other { background: #ec4899; }
        .loc-cell .loc-num { font-size: 0.7rem; }

        /* Tooltip */
        .loc-cell .tooltip { display: none; position: absolute; bottom: calc(100% + 6px); left: 50%; transform: translateX(-50%); background: #1f2937; color: #fff; padding: 4px 8px; border-radius: 6px; font-size: 0.7rem; font-weight: 500; white-space: nowrap; z-index: 20; pointer-events: none; }
        .loc-cell .tooltip::after { content: ''; position: absolute; top: 100%; left: 50%; transform: translateX(-50%); border: 4px solid transparent; border-top-color: #1f2937; }
        .loc-cell:hover .tooltip { display: block; }

        /* Stat boxes row */
        .stat-boxes { display: flex; gap: 0.75rem; margin-bottom: 1.5rem; flex-wrap: wrap; }
        .stat-box { flex: 1; min-width: 100px; background: #fff; border-radius: 0.75rem; border: 1px solid #f3f4f6; padding: 0.75rem 1rem; text-align: center; }
        .stat-box .sb-value { font-size: 1.5rem; font-weight: 700; }
        .stat-box .sb-label { font-size: 0.75rem; color: #6b7280; margin-top: 0.125rem; }

        /* Stages */
        .stages-card { background: #fff; border-radius: 1rem; border: 1px solid #f3f4f6; padding: 1.5rem; box-shadow: 0 1px 2px rgba(0,0,0,0.04); }
        .stage-row { display: flex; gap: 1rem; }
        .stage-timeline { display: flex; flex-direction: column; align-items: center; }
        .stage-icon { width: 20px; height: 20px; border-radius: 9999px; display: flex; align-items: center; justify-content: center; font-size: 0.75rem; flex-shrink: 0; }
        .stage-icon.completed { background: #dcfce7; color: #16a34a; }
        .stage-icon.in-progress { background: #dbeafe; color: #2563eb; }
        .stage-icon.delayed { background: #fef3c7; color: #d97706; }
        .stage-icon.pending { background: #f3f4f6; color: #9ca3af; }
        .stage-line { width: 2px; flex: 1; margin: 4px 0; }
        .stage-line.completed { background: #bbf7d0; }
        .stage-line.default { background: #e5e7eb; }
        .stage-content { padding-bottom: 1.5rem; flex: 1; }
        .stage-name { font-weight: 500; font-size: 0.875rem; color: #1f2937; }
        .stage-badge { display: inline-flex; padding: 0.125rem 0.5rem; border-radius: 9999px; font-size: 0.75rem; font-weight: 500; margin-left: 0.5rem; }
        .stage-badge.completed { background: #f0fdf4; color: #15803d; }
        .stage-badge.in-progress { background: #eff6ff; color: #1d4ed8; }
        .stage-badge.delayed { background: #fffbeb; color: #b45309; }
        .stage-badge.pending { background: #f9fafb; color: #6b7280; }
        .stage-desc { font-size: 0.75rem; color: #6b7280; margin-top: 0.125rem; }
        .stage-duration { font-size: 0.75rem; color: #9ca3af; margin-top: 0.25rem; }

        /* Empty / Loading */
        .empty-state { text-align: center; padding: 5rem 1rem; }
        .empty-icon { font-size: 4rem; color: #d1d5db; margin-bottom: 1rem; }
        .empty-title { font-size: 1.125rem; font-weight: 600; color: #6b7280; margin-bottom: 0.5rem; }
        .empty-text { font-size: 0.875rem; color: #9ca3af; }
        .loading { display: flex; align-items: center; justify-content: center; padding: 5rem; }
        .spinner { width: 2rem; height: 2rem; border: 3px solid #e5e7eb; border-top-color: #3b82f6; border-radius: 9999px; animation: spin 0.8s linear infinite; }
        @keyframes spin { to { transform: rotate(360deg); } }
        .footer { text-align: center; font-size: 0.75rem; color: #9ca3af; margin-top: 3rem; padding-bottom: 2rem; }
        .section-title { font-weight: 600; color: #111827; margin-bottom: 1rem; }
    </style>
</head>
<body>
    <div id="app"></div>
    <script>
    // ============ HELPERS ============
    function getWallStats(wall) {
        const locs = wall.locations || [];
        const total = locs.length;
        const rodsInstalled = locs.filter(l => l.status === 'Rods Installed').length;
        const holesDrilled = locs.filter(l => l.status === 'Holes Drilled').length;
        const rebar = locs.filter(l => l.status === 'Rebar').length;
        const notComplete = locs.filter(l => l.status === 'Not Complete').length;
        const hss = locs.filter(l => l.status === 'HSS').length;
        const other = locs.filter(l => l.status === 'Other').length;
        return { total, rodsInstalled, holesDrilled, rebar, notComplete, hss, other, progressPercentage: total > 0 ? Math.round((rodsInstalled / total) * 100) : 0 };
    }
    function getProjectStats(project) {
        const walls = Object.values(project.walls || {});
        let totalLocations = 0, completedLocations = 0, wallCount = walls.length;
        walls.forEach(w => { const locs = w.locations || []; totalLocations += locs.length; completedLocations += locs.filter(l => l.status === 'Rods Installed').length; });
        return { totalLocations, completedLocations, wallCount, progressPercentage: totalLocations > 0 ? Math.round((completedLocations / totalLocations) * 100) : 0 };
    }
    function getRepairTypeLabel(t) { return { concrete: 'Concrete Repair', fin: 'Fin Repair', plate: 'Plate Installation' }[t] || t; }
    function getRepairTypeIcon(t) { return { concrete: '\u{1F3D7}\uFE0F', fin: '\u{1F4D0}', plate: '\u{1F529}' }[t] || '\u{1F3D7}\uFE0F'; }
    function progressColor(p) { return p >= 75 ? 'green' : p >= 40 ? 'blue' : 'gray'; }
    function progressColorClass(p) { const c = progressColor(p); return c === 'green' ? 'bg-green' : c === 'blue' ? 'bg-blue' : 'bg-gray-fill'; }
    function progressTextClass(p) { const c = progressColor(p); return c === 'green' ? 'text-green' : c === 'blue' ? 'text-blue' : 'text-gray'; }
    function statusCellClass(s) { return { 'Rods Installed': 'cell-green', 'Holes Drilled': 'cell-blue', 'Rebar': 'cell-orange', 'HSS': 'cell-purple', 'Other': 'cell-pink' }[s] || 'cell-gray'; }
    function locCellClass(s) { return { 'Rods Installed': 'status-installed', 'Holes Drilled': 'status-drilled', 'Rebar': 'status-rebar', 'HSS': 'status-hss', 'Other': 'status-other' }[s] || 'status-notcomplete'; }
    function esc(s) { const d = document.createElement('div'); d.textContent = s; return d.innerHTML; }

    // ============ STATE ============
    let projects = [], selectedType = 'all', selectedProject = null, selectedWallName = null, loading = true, lastUpdated = null;

    // ============ FETCH ============
    async function fetchProjects() {
        loading = true; render();
        try {
            const res = await fetch('api/sync.php', { cache: 'no-store', headers: { 'Cache-Control': 'no-cache' } });
            const data = await res.json();
            projects = Array.isArray(data) ? data : [];
            lastUpdated = new Date();
            if (selectedProject) { selectedProject = projects.find(p => p.id === selectedProject.id) || null; }
        } catch (err) { console.error('Fetch failed:', err); }
        finally { loading = false; render(); }
    }

    // ============ RENDER: Circular Progress ============
    function renderCircle(stats) {
        const p = stats.progressPercentage, d = `${p * 2.64} ${264 - p * 2.64}`, c = p >= 75 ? '#22c55e' : p >= 40 ? '#3b82f6' : '#9ca3af';
        return `<div class="circle-wrap"><div class="circle-container"><svg viewBox="0 0 100 100"><circle cx="50" cy="50" r="42" fill="none" stroke="#e5e7eb" stroke-width="8"/><circle cx="50" cy="50" r="42" fill="none" stroke="${c}" stroke-width="8" stroke-linecap="round" stroke-dasharray="${d}"/></svg><div class="circle-label">${stats.rodsInstalled}/${stats.total}</div></div></div>`;
    }

    // ============ RENDER: Wall Card (clickable) ============
    function renderWallCard(wallName, wall) {
        const s = getWallStats(wall);
        const locs = (wall.locations || []).map(l => `<div class="heatmap-cell ${statusCellClass(l.status)}" title="Bay ${l.bay}, ${esc(l.window)}-${l.locationNumber}: ${esc(l.status)}"></div>`).join('');
        return `<div class="wall-card" onclick="selectedWallName='${esc(wallName)}';render();">
            <div class="wall-header">
                <span class="wall-name">${esc(wall.name)}</span>
                <span class="wall-pct ${progressTextClass(s.progressPercentage)}">${s.progressPercentage}%</span>
            </div>
            ${renderCircle(s)}
            <div class="status-grid">
                <div class="status-item"><div class="status-dot dot-green"></div>Installed: <strong>${s.rodsInstalled}</strong></div>
                <div class="status-item"><div class="status-dot dot-blue"></div>Drilled: <strong>${s.holesDrilled}</strong></div>
                <div class="status-item"><div class="status-dot dot-orange"></div>Rebar: <strong>${s.rebar}</strong></div>
                <div class="status-item"><div class="status-dot dot-gray"></div>Pending: <strong>${s.notComplete}</strong></div>
                <div class="status-item"><div class="status-dot dot-purple"></div>HSS: <strong>${s.hss}</strong></div>
                <div class="status-item"><div class="status-dot dot-pink"></div>Other: <strong>${s.other}</strong></div>
            </div>
            <div class="heatmap">
                <div class="heatmap-label">${wall.bays} bays \u00D7 ${(wall.windows || []).length} windows</div>
                <div class="heatmap-grid">${locs}</div>
            </div>
        </div>`;
    }

    // ============ RENDER: Bay Grid (wall detail) ============
    function renderBayGrid(wall, bayNum) {
        const windows = wall.windows || [];
        const locsPerWindow = wall.locationsPerWindow || 4;
        const cols = windows.length + 1; // +1 for row label column

        let html = `<div class="bay-section">
            <div class="bay-title">Bay ${bayNum}</div>
            <div class="bay-grid" style="grid-template-columns: 32px repeat(${windows.length}, 1fr);">`;

        // Header row: empty corner + window labels
        html += `<div class="bay-col-label"></div>`;
        for (const w of windows) {
            html += `<div class="bay-col-label">${esc(w)}</div>`;
        }

        // Data rows: 1..locationsPerWindow
        for (let row = 1; row <= locsPerWindow; row++) {
            html += `<div class="bay-row-label">${row}</div>`;
            for (const w of windows) {
                const loc = (wall.locations || []).find(l => l.bay === bayNum && l.window === w && l.locationNumber === row);
                if (loc) {
                    html += `<div class="loc-cell ${locCellClass(loc.status)}">
                        <span class="loc-num">${row}</span>
                        <div class="tooltip">${esc(w)}${row} \u2022 ${esc(loc.status)}${loc.technician ? ' \u2022 ' + esc(loc.technician) : ''}</div>
                    </div>`;
                } else {
                    html += `<div class="loc-cell status-notcomplete"><span class="loc-num">${row}</span></div>`;
                }
            }
        }

        html += `</div></div>`;
        return html;
    }

    // ============ RENDER: Wall Detail View ============
    function renderWallDetail(project, wallName) {
        const wall = (project.walls || {})[wallName];
        if (!wall) return '<div class="empty-state"><div class="empty-title">Wall not found</div></div>';

        const s = getWallStats(wall);
        const bays = wall.bays || 0;

        let baysHtml = '';
        for (let b = 1; b <= bays; b++) {
            baysHtml += renderBayGrid(wall, b);
        }

        return `
        <div class="header">
            <div class="header-inner">
                <div class="detail-header" style="width:100%">
                    <button class="btn-back" onclick="selectedWallName=null;render();">\u2190</button>
                    <div class="detail-title">
                        <h1 style="font-size:1.25rem;font-weight:700;">${esc(wall.name)}</h1>
                        <p style="font-size:0.875rem;color:#6b7280;">${esc(project.name)} \u00B7 ${esc(project.location)}</p>
                    </div>
                    <div class="detail-progress">
                        <div class="pct ${progressTextClass(s.progressPercentage)}">${s.progressPercentage}%</div>
                        <div class="sub">${s.rodsInstalled}/${s.total} complete</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="main">
            <div class="stat-boxes">
                <div class="stat-box"><div class="sb-value text-green">${s.rodsInstalled}</div><div class="sb-label">Rods Installed</div></div>
                <div class="stat-box"><div class="sb-value text-blue">${s.holesDrilled}</div><div class="sb-label">Holes Drilled</div></div>
                <div class="stat-box"><div class="sb-value" style="color:#f97316">${s.rebar}</div><div class="sb-label">Rebar</div></div>
                <div class="stat-box"><div class="sb-value text-gray">${s.notComplete}</div><div class="sb-label">Not Complete</div></div>
                <div class="stat-box"><div class="sb-value" style="color:#a855f7">${s.hss}</div><div class="sb-label">HSS</div></div>
                <div class="stat-box"><div class="sb-value" style="color:#ec4899">${s.other}</div><div class="sb-label">Other</div></div>
            </div>

            <div class="progress-bar progress-bar-lg" style="margin-bottom:2rem;">
                <div class="progress-fill ${progressColorClass(s.progressPercentage)}" style="width:${s.progressPercentage}%"></div>
            </div>

            ${baysHtml}

            <div class="overall-card" style="margin-top:1.5rem;">
                <h3 class="section-title">Legend</h3>
                <div class="status-legend">
                    <div class="legend-item"><div class="legend-dot dot-green"></div>Rods Installed</div>
                    <div class="legend-item"><div class="legend-dot dot-blue"></div>Holes Drilled</div>
                    <div class="legend-item"><div class="legend-dot dot-orange"></div>Rebar</div>
                    <div class="legend-item"><div class="legend-dot dot-gray"></div>Not Complete</div>
                    <div class="legend-item"><div class="legend-dot dot-purple"></div>HSS</div>
                    <div class="legend-item"><div class="legend-dot dot-pink"></div>Other</div>
                </div>
            </div>
        </div>`;
    }

    // ============ RENDER: Stages ============
    function renderStages(stages) {
        if (!stages || !stages.length) return '';
        const sorted = [...stages].sort((a, b) => a.order - b.order);
        return `<div class="stages-card"><h3 class="section-title">Project Stages</h3>${sorted.map((st, i) => {
            const sc = st.status === 'in-progress' ? 'in-progress' : st.status;
            const bl = { completed: 'Completed', 'in-progress': 'In Progress', delayed: 'Delayed', pending: 'Pending' }[st.status] || 'Pending';
            const ic = { completed: '\u2713', 'in-progress': '\u25F7', delayed: '\u26A0', pending: '\u25CB' }[st.status] || '\u25CB';
            return `<div class="stage-row"><div class="stage-timeline"><div class="stage-icon ${sc}">${ic}</div>${i < sorted.length - 1 ? `<div class="stage-line ${st.status === 'completed' ? 'completed' : 'default'}"></div>` : ''}</div><div class="stage-content"><div><span class="stage-name">${esc(st.name)}</span><span class="stage-badge ${sc}">${bl}</span></div><div class="stage-desc">${esc(st.description || '')}</div><div class="stage-duration">${st.duration} day${st.duration !== 1 ? 's' : ''}</div></div></div>`;
        }).join('')}</div>`;
    }

    // ============ RENDER: Project Detail (walls overview) ============
    function renderDetail(project) {
        const s = getProjectStats(project);
        const walls = Object.entries(project.walls || {}).sort(([a], [b]) => a.localeCompare(b));
        const all = Object.values(project.walls || {}).flatMap(w => w.locations || []);
        const inst = all.filter(l => l.status === 'Rods Installed').length;
        const drill = all.filter(l => l.status === 'Holes Drilled').length;
        const reb = all.filter(l => l.status === 'Rebar').length;
        const nc = all.filter(l => l.status === 'Not Complete').length;
        const hssCount = all.filter(l => l.status === 'HSS').length;
        const otherCount = all.filter(l => l.status === 'Other').length;

        const wallsHtml = walls.map(([name, w]) => renderWallCard(name, w)).join('');

        return `
        <div class="header">
            <div class="header-inner">
                <div class="detail-header" style="width:100%">
                    <button class="btn-back" onclick="selectedProject=null;selectedWallName=null;render();">\u2190</button>
                    <div class="detail-title">
                        <h1 style="font-size:1.25rem;font-weight:700;">${esc(project.name)}</h1>
                        <p style="font-size:0.875rem;color:#6b7280;">${esc(project.location)} \u00B7 ${getRepairTypeLabel(project.repairType)}</p>
                    </div>
                    <div class="detail-progress">
                        <div class="pct ${progressTextClass(s.progressPercentage)}">${s.progressPercentage}%</div>
                        <div class="sub">${s.completedLocations}/${s.totalLocations} complete</div>
                    </div>
                </div>
            </div>
        </div>
        <div class="main">
            <div class="overall-card">
                <div class="overall-header">
                    <h3 class="section-title" style="margin-bottom:0">Overall Progress</h3>
                    <span style="font-size:0.875rem;color:#6b7280;">${s.wallCount} walls \u00B7 ${s.totalLocations} locations</span>
                </div>
                <div class="progress-bar progress-bar-lg" style="margin-top:0.75rem;">
                    <div class="progress-fill ${progressColorClass(s.progressPercentage)}" style="width:${s.progressPercentage}%"></div>
                </div>
                <div class="status-legend">
                    <div class="legend-item"><div class="legend-dot dot-green"></div>Rods Installed: <strong>${inst}</strong></div>
                    <div class="legend-item"><div class="legend-dot dot-blue"></div>Holes Drilled: <strong>${drill}</strong></div>
                    <div class="legend-item"><div class="legend-dot dot-orange"></div>Rebar: <strong>${reb}</strong></div>
                    <div class="legend-item"><div class="legend-dot dot-gray"></div>Not Complete: <strong>${nc}</strong></div>
                    <div class="legend-item"><div class="legend-dot dot-purple"></div>HSS: <strong>${hssCount}</strong></div>
                    <div class="legend-item"><div class="legend-dot dot-pink"></div>Other: <strong>${otherCount}</strong></div>
                </div>
            </div>

            <h3 class="section-title">Walls <span style="font-size:0.8rem;color:#9ca3af;font-weight:400;">(click to view bays)</span></h3>
            <div class="walls-grid">${wallsHtml}</div>

            ${renderStages(project.stages)}
        </div>`;
    }

    // ============ RENDER: Project Card ============
    function renderCard(project) {
        const s = getProjectStats(project), ud = project.updatedAt ? new Date(project.updatedAt).toLocaleDateString() : '';
        return `<div class="project-card" onclick="selectedProject=projects.find(p=>p.id==='${project.id}');selectedWallName=null;render();">
            <div class="project-card-header">
                <div class="project-info">
                    <div class="project-icon">${getRepairTypeIcon(project.repairType)}</div>
                    <div>
                        <div class="project-name">${esc(project.name)}</div>
                        <div class="project-location">\u{1F4CD} ${esc(project.location)}</div>
                    </div>
                </div>
                <span class="badge">${getRepairTypeLabel(project.repairType)}</span>
            </div>
            <div class="progress-section">
                <div class="progress-header">
                    <span class="progress-text">${s.completedLocations} of ${s.totalLocations} completed</span>
                    <span class="progress-pct ${progressTextClass(s.progressPercentage)}">${s.progressPercentage}%</span>
                </div>
                <div class="progress-bar">
                    <div class="progress-fill ${progressColorClass(s.progressPercentage)}" style="width:${s.progressPercentage}%"></div>
                </div>
            </div>
            <div class="stats-row">
                <div class="stat-item"><span class="stat-dot" style="background:#60a5fa;"></span>${s.wallCount} walls</div>
                <div class="stat-item"><span class="stat-dot" style="background:#9ca3af;"></span>${s.totalLocations} locations</div>
                ${ud ? `<div class="stat-item" style="margin-left:auto;">\u{1F4C5} ${ud}</div>` : ''}
            </div>
        </div>`;
    }

    // ============ RENDER: Project List ============
    function renderList() {
        const filtered = selectedType === 'all' ? projects : projects.filter(p => p.repairType === selectedType);
        const tp = projects.length, tl = projects.reduce((s, p) => s + getProjectStats(p).totalLocations, 0), tc = projects.reduce((s, p) => s + getProjectStats(p).completedLocations, 0), op = tl > 0 ? Math.round((tc / tl) * 100) : 0;
        const counts = { concrete: 0, fin: 0, plate: 0 }; projects.forEach(p => { if (counts[p.repairType] !== undefined) counts[p.repairType]++; });
        let content;
        if (loading) content = '<div class="loading"><div class="spinner"></div></div>';
        else if (!filtered.length) content = '<div class="empty-state"><div class="empty-icon">\u{1F3D7}\uFE0F</div><div class="empty-title">No Projects Yet</div><div class="empty-text">Sync project data from the iOS app.</div></div>';
        else content = `<div class="projects-grid">${filtered.map(renderCard).join('')}</div>`;

        return `
        <div class="header">
            <div class="header-inner">
                <div><h1>Repair Tracker Dashboard</h1><p>UBC Facade Rod Installation Progress</p></div>
                <button class="btn btn-secondary" onclick="fetchProjects();">\u{1F504} Refresh</button>
            </div>
        </div>
        <div class="main">
            <div class="summary-grid">
                <div class="summary-card"><div class="label">Total Projects</div><div class="value">${tp}</div></div>
                <div class="summary-card"><div class="label">Total Locations</div><div class="value">${tl.toLocaleString()}</div></div>
                <div class="summary-card"><div class="label">Completed</div><div class="value text-green">${tc.toLocaleString()}</div></div>
                <div class="summary-card"><div class="label">Overall Progress</div><div class="value ${progressTextClass(op)}">${op}%</div></div>
            </div>
            <div class="filter-tabs">
                <button class="filter-tab ${selectedType === 'all' ? 'active' : ''}" onclick="selectedType='all';render();">All (${tp})</button>
                <button class="filter-tab ${selectedType === 'concrete' ? 'active' : ''}" onclick="selectedType='concrete';render();">\u{1F3D7}\uFE0F Concrete (${counts.concrete})</button>
                <button class="filter-tab ${selectedType === 'fin' ? 'active' : ''}" onclick="selectedType='fin';render();">\u{1F4D0} Fin (${counts.fin})</button>
                <button class="filter-tab ${selectedType === 'plate' ? 'active' : ''}" onclick="selectedType='plate';render();">\u{1F529} Plate (${counts.plate})</button>
            </div>
            ${content}
            ${lastUpdated ? `<div class="footer">Last updated: ${lastUpdated.toLocaleString()}</div>` : ''}
        </div>`;
    }

    // ============ MAIN RENDER ============
    function render() {
        const app = document.getElementById('app');
        if (selectedProject && selectedWallName) {
            app.innerHTML = renderWallDetail(selectedProject, selectedWallName);
        } else if (selectedProject) {
            app.innerHTML = renderDetail(selectedProject);
        } else {
            app.innerHTML = renderList();
        }
    }

    fetchProjects();
    </script>
</body>
</html>

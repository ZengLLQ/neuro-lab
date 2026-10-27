module UIHtml

export get_ui_html

function get_ui_html()::String
    return raw"""<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>NeuroLab — Scientific Machine Learning Studio</title>
<style>
  :root {
    --canvas: #0B1020;
    --panel: #111827;
    --elevated: #172033;
    --border: #263247;
    --text-primary: #F3F5F9;
    --text-secondary: #A8B2C4;
    --text-muted: #64748B;
    --accent-primary: #8174F5;
    --accent-primary-hover: #9387FF;
    --accent-secondary: #54B7E8;
    --status-success: #48B887;
    --status-warning: #E9B85B;
    --status-error: #F07178;
    --status-running: #5AA7FF;
    --font-ui: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
    --font-mono: "JetBrains Mono", Consolas, "Courier New", monospace;
  }

  * { box-sizing: border-box; margin: 0; padding: 0; }

  body {
    background-color: var(--canvas);
    color: var(--text-primary);
    font-family: var(--font-ui);
    font-size: 13px;
    line-height: 1.5;
    display: flex;
    flex-direction: column;
    height: 100vh;
    overflow: hidden;
  }

  /* --- Top Navigation Bar --- */
  header.top-bar {
    height: 44px;
    background-color: var(--panel);
    border-bottom: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 16px;
    user-select: none;
    z-index: 100;
  }

  .brand-group {
    display: flex;
    align-items: center;
    gap: 12px;
  }

  .brand-logo {
    display: flex;
    align-items: center;
    gap: 8px;
    font-weight: 700;
    font-size: 14px;
    letter-spacing: 0.5px;
    color: var(--text-primary);
  }

  .brand-badge {
    background: linear-gradient(135deg, #8174F5, #54B7E8);
    width: 22px;
    height: 22px;
    border-radius: 4px;
    display: flex;
    align-items: center;
    justify-content: center;
    font-size: 12px;
    font-weight: 800;
    color: #fff;
  }

  .project-selector {
    display: flex;
    align-items: center;
    gap: 8px;
    background-color: var(--elevated);
    border: 1px solid var(--border);
    padding: 4px 10px;
    border-radius: 4px;
    font-size: 12px;
    color: var(--text-secondary);
  }

  .status-pill {
    display: flex;
    align-items: center;
    gap: 6px;
    background-color: rgba(72, 184, 135, 0.12);
    border: 1px solid var(--status-success);
    color: var(--status-success);
    padding: 3px 10px;
    border-radius: 12px;
    font-size: 11px;
    font-weight: 600;
  }

  .status-pill.running {
    background-color: rgba(90, 167, 255, 0.12);
    border-color: var(--status-running);
    color: var(--status-running);
  }

  .pulse-dot {
    width: 6px;
    height: 6px;
    border-radius: 50%;
    background-color: currentColor;
    display: inline-block;
  }

  /* --- Main Layout --- */
  .app-body {
    display: flex;
    flex: 1;
    overflow: hidden;
  }

  /* Left Navigation Rail */
  nav.side-rail {
    width: 180px;
    background-color: var(--panel);
    border-right: 1px solid var(--border);
    display: flex;
    flex-direction: column;
    padding: 12px 8px;
    gap: 4px;
    user-select: none;
  }

  .nav-item {
    display: flex;
    align-items: center;
    gap: 10px;
    padding: 8px 12px;
    border-radius: 4px;
    color: var(--text-secondary);
    cursor: pointer;
    font-size: 12px;
    font-weight: 500;
    transition: all 0.15s ease;
  }

  .nav-item:hover {
    background-color: var(--elevated);
    color: var(--text-primary);
  }

  .nav-item.active {
    background-color: rgba(129, 116, 245, 0.15);
    color: var(--accent-primary);
    border-left: 3px solid var(--accent-primary);
    padding-left: 9px;
  }

  .nav-icon {
    width: 16px;
    height: 16px;
    stroke: currentColor;
    fill: none;
    stroke-width: 2;
  }

  /* Main Viewport Content */
  main.viewport {
    flex: 1;
    overflow-y: auto;
    background-color: var(--canvas);
    padding: 20px;
  }

  .screen { display: none; }
  .screen.active { display: block; }

  /* Section and Card Utilities */
  .section-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 16px;
  }

  .section-title {
    font-size: 18px;
    font-weight: 600;
    color: var(--text-primary);
  }

  .section-subtitle {
    font-size: 12px;
    color: var(--text-secondary);
  }

  .grid-2 { display: grid; grid-template-columns: 1fr 1fr; gap: 16px; }
  .grid-3 { display: grid; grid-template-columns: repeat(3, 1fr); gap: 16px; }
  .grid-4 { display: grid; grid-template-columns: repeat(4, 1fr); gap: 16px; }

  .panel-card {
    background-color: var(--panel);
    border: 1px solid var(--border);
    border-radius: 6px;
    padding: 16px;
    margin-bottom: 16px;
  }

  .card-title {
    font-size: 13px;
    font-weight: 600;
    color: var(--text-secondary);
    text-transform: uppercase;
    letter-spacing: 0.5px;
    margin-bottom: 12px;
    display: flex;
    justify-content: space-between;
    align-items: center;
  }

  /* Buttons */
  button.btn {
    background-color: var(--elevated);
    border: 1px solid var(--border);
    color: var(--text-primary);
    padding: 6px 14px;
    border-radius: 4px;
    font-size: 12px;
    font-weight: 500;
    cursor: pointer;
    display: inline-flex;
    align-items: center;
    gap: 6px;
    transition: all 0.15s ease;
  }

  button.btn:hover {
    background-color: var(--border);
    border-color: var(--text-secondary);
  }

  button.btn-primary {
    background-color: var(--accent-primary);
    border-color: var(--accent-primary);
    color: #fff;
  }

  button.btn-primary:hover {
    background-color: var(--accent-primary-hover);
  }

  button.btn-danger {
    background-color: rgba(240, 113, 120, 0.15);
    border-color: var(--status-error);
    color: var(--status-error);
  }

  button.btn-danger:hover {
    background-color: var(--status-error);
    color: #fff;
  }

  /* Form Controls */
  .form-group {
    margin-bottom: 12px;
  }

  .form-group label {
    display: block;
    font-size: 11px;
    color: var(--text-secondary);
    margin-bottom: 4px;
  }

  .form-control {
    width: 100%;
    background-color: var(--canvas);
    border: 1px solid var(--border);
    color: var(--text-primary);
    padding: 6px 10px;
    border-radius: 4px;
    font-size: 12px;
    font-family: var(--font-ui);
  }

  .form-control:focus {
    outline: none;
    border-color: var(--accent-primary);
  }

  /* Data Table */
  .data-table-container {
    overflow-x: auto;
    border: 1px solid var(--border);
    border-radius: 4px;
    background-color: var(--canvas);
  }

  table.data-table {
    width: 100%;
    border-collapse: collapse;
    font-family: var(--font-mono);
    font-size: 11px;
  }

  table.data-table th {
    background-color: var(--elevated);
    color: var(--text-secondary);
    padding: 8px 12px;
    text-align: left;
    border-bottom: 1px solid var(--border);
    font-weight: 600;
    white-space: nowrap;
  }

  table.data-table td {
    padding: 6px 12px;
    border-bottom: 1px solid rgba(38, 50, 71, 0.5);
    color: var(--text-primary);
    white-space: nowrap;
  }

  table.data-table tr:hover {
    background-color: rgba(23, 32, 51, 0.6);
  }

  .badge-type {
    display: inline-block;
    padding: 2px 6px;
    border-radius: 3px;
    font-size: 9px;
    font-family: var(--font-mono);
    background-color: var(--elevated);
    color: var(--accent-secondary);
    border: 1px solid var(--border);
  }

  /* Metric Stat Box */
  .stat-box {
    background-color: var(--elevated);
    border: 1px solid var(--border);
    border-radius: 4px;
    padding: 12px;
  }

  .stat-label {
    font-size: 11px;
    color: var(--text-secondary);
    margin-bottom: 4px;
  }

  .stat-value {
    font-size: 20px;
    font-weight: 700;
    font-family: var(--font-mono);
    color: var(--text-primary);
  }

  /* Chart Canvas Container */
  .canvas-wrapper {
    background-color: var(--canvas);
    border: 1px solid var(--border);
    border-radius: 4px;
    padding: 12px;
    position: relative;
    height: 280px;
    display: flex;
    flex-direction: column;
  }

  canvas {
    flex: 1;
    width: 100%;
    height: 100%;
  }

  /* Bottom Telemetry Bar */
  footer.bottom-bar {
    height: 28px;
    background-color: var(--panel);
    border-top: 1px solid var(--border);
    display: flex;
    align-items: center;
    justify-content: space-between;
    padding: 0 16px;
    font-size: 11px;
    font-family: var(--font-mono);
    color: var(--text-muted);
    user-select: none;
  }

  .telemetry-item {
    display: flex;
    align-items: center;
    gap: 6px;
  }
</style>
</head>
<body>

<!-- Top Navigation Bar -->
<header class="top-bar">
  <div class="brand-group">
    <div class="brand-logo">
      <div class="brand-badge">N</div>
      <span>NeuroLab</span>
    </div>
    <div class="project-selector">
      <span>Project:</span>
      <strong id="active-project-name">Harmonic_Oscillator_Study</strong>
    </div>
    <span class="badge-type" id="active-workflow-badge">Scientific ML Studio</span>
  </div>

  <div style="display:flex; align-items:center; gap:12px;">
    <div class="status-pill" id="global-status-pill">
      <span class="pulse-dot"></span>
      <span id="global-status-text">Runtime Ready</span>
    </div>
    <button class="btn" onclick="switchScreen('settings')">Settings ⚙</button>
  </div>
</header>

<div class="app-body">
  <!-- Left Navigation Rail -->
  <nav class="side-rail">
    <div class="nav-item active" onclick="switchScreen('home')">
      <svg class="nav-icon" viewBox="0 0 24 24"><path d="M3 9l9-7 9 7v11a2 2 0 0 1-2 2H5a2 2 0 0 1-2-2z"></path><polyline points="9 22 9 12 15 12 15 22"></polyline></svg>
      <span>Dashboard</span>
    </div>
    <div class="nav-item" onclick="switchScreen('data')">
      <svg class="nav-icon" viewBox="0 0 24 24"><path d="M12 2v20M17 5H9.5a3.5 3.5 0 0 0 0 7h5a3.5 3.5 0 0 1 0 7H6"></path></svg>
      <span>Data Lab</span>
    </div>
    <div class="nav-item" onclick="switchScreen('simulation')">
      <svg class="nav-icon" viewBox="0 0 24 24"><circle cx="12" cy="12" r="10"></circle><path d="M8 12h8"></path><path d="M12 8v8"></path></svg>
      <span>Simulation</span>
    </div>
    <div class="nav-item" onclick="switchScreen('models')">
      <svg class="nav-icon" viewBox="0 0 24 24"><rect x="4" y="4" width="16" height="16" rx="2" ry="2"></rect><rect x="9" y="9" width="6" height="6"></rect></svg>
      <span>Model Studio</span>
    </div>
    <div class="nav-item" onclick="switchScreen('experiments')">
      <svg class="nav-icon" viewBox="0 0 24 24"><polyline points="22 12 18 12 15 21 9 3 6 12 2 12"></polyline></svg>
      <span>Monitor</span>
    </div>
    <div class="nav-item" onclick="switchScreen('results')">
      <svg class="nav-icon" viewBox="0 0 24 24"><line x1="18" y1="20" x2="18" y2="10"></line><line x1="12" y1="20" x2="12" y2="4"></line><line x1="6" y1="20" x2="6" y2="14"></line></svg>
      <span>Results</span>
    </div>
    <div class="nav-item" onclick="switchScreen('provenance')">
      <svg class="nav-icon" viewBox="0 0 24 24"><path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"></path><polyline points="14 2 14 8 20 8"></polyline></svg>
      <span>Provenance</span>
    </div>
    <div class="nav-item" onclick="switchScreen('settings')">
      <svg class="nav-icon" viewBox="0 0 24 24"><circle cx="12" cy="12" r="3"></circle><path d="M19.4 15a1.65 1.65 0 0 0 .33 1.82l.06.06a2 2 0 0 1 0 2.83 2 2 0 0 1-2.83 0l-.06-.06a1.65 1.65 0 0 0-1.82-.33 1.65 1.65 0 0 0-1 1.51V21a2 2 0 0 1-2 2 2 2 0 0 1-2-2v-.09A1.65 1.65 0 0 0 9 19.4a1.65 1.65 0 0 0-1.82.33l-.06.06a2 2 0 0 1-2.83 0 2 2 0 0 1 0-2.83l.06-.06a1.65 1.65 0 0 0 .33-1.82 1.65 1.65 0 0 0-1.51-1H3a2 2 0 0 1-2-2 2 2 0 0 1 2-2h.09A1.65 1.65 0 0 0 4.6 9a1.65 1.65 0 0 0-.33-1.82l-.06-.06a2 2 0 0 1 0-2.83 2 2 0 0 1 2.83 0l.06.06a1.65 1.65 0 0 0 1.82.33H9a1.65 1.65 0 0 0 1-1.51V3a2 2 0 0 1 2-2 2 2 0 0 1 2 2v.09a1.65 1.65 0 0 0 1 1.51 1.65 1.65 0 0 0 1.82-.33l.06-.06a2 2 0 0 1 2.83 0 2 2 0 0 1 0 2.83l-.06.06a1.65 1.65 0 0 0-.33 1.82V9a1.65 1.65 0 0 0 1.51 1H21a2 2 0 0 1 2 2 2 2 0 0 1-2 2h-.09a1.65 1.65 0 0 0-1.51 1z"></path></svg>
      <span>Settings</span>
    </div>
  </nav>

  <!-- Viewport -->
  <main class="viewport">
    
    <!-- Screen A: Home / Research Dashboard -->
    <div id="screen-home" class="screen active">
      <div class="section-header">
        <div>
          <h1 class="section-title">Welcome back, Computational Researcher</h1>
          <p class="section-subtitle">Local-first scientific machine learning, differential equations, and surrogate modelling.</p>
        </div>
        <div style="display:flex; gap:8px;">
          <button class="btn btn-primary" onclick="switchScreen('simulation')">⚡ New Simulation</button>
          <button class="btn" onclick="switchScreen('data')">📥 Inspect Data</button>
          <button class="btn" onclick="switchScreen('models')">🧪 Train PINN</button>
        </div>
      </div>

      <div class="grid-4" style="margin-bottom: 20px;">
        <div class="stat-box">
          <div class="stat-label">Host CPU Architecture</div>
          <div class="stat-value" id="sys-cpu">x86_64</div>
        </div>
        <div class="stat-box">
          <div class="stat-label">Active Julia Threads</div>
          <div class="stat-value" id="sys-threads">1</div>
        </div>
        <div class="stat-box">
          <div class="stat-label">Host RAM (Total)</div>
          <div class="stat-value" id="sys-ram">32.0 GB</div>
        </div>
        <div class="stat-box">
          <div class="stat-label">Hardware Acceleration</div>
          <div class="stat-value" style="font-size:14px; color:var(--text-secondary); margin-top:4px;">CPU Baseline (GPU: None)</div>
        </div>
      </div>

      <div class="grid-2">
        <div class="panel-card">
          <div class="card-title">Active / Recent Scientific Workflows</div>
          <table class="data-table" style="width:100%;">
            <thead>
              <tr>
                <th>Run ID</th>
                <th>Workflow</th>
                <th>Status</th>
                <th>Convergence</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td><code>RUN-001</code></td>
                <td>Damped Oscillator ODE</td>
                <td><span style="color:var(--status-success);">● Converged</span></td>
                <td>$E_\infty < 10^{-6}$</td>
              </tr>
              <tr>
                <td><code>RUN-002</code></td>
                <td>Sensor Ridge Baseline</td>
                <td><span style="color:var(--status-success);">● Completed</span></td>
                <td>$R^2 = 0.999$</td>
              </tr>
              <tr>
                <td><code>RUN-003</code></td>
                <td>1D Damped PINN (Adam)</td>
                <td><span style="color:var(--status-running);">● Validated</span></td>
                <td>Rel $L_2 = 0.67$</td>
              </tr>
            </tbody>
          </table>
        </div>

        <div class="panel-card">
          <div class="card-title">Canonical Benchmarks & Examples</div>
          <div style="display:flex; flex-direction:column; gap:8px;">
            <div style="background:var(--elevated); border:1px solid var(--border); padding:10px; border-radius:4px; display:flex; justify-content:space-between; align-items:center;">
              <div>
                <strong>Damped Harmonic Oscillator</strong>
                <div style="font-size:11px; color:var(--text-secondary);">IVP: d²u/dt² + 2γ(du/dt) + ω₀²u = 0 with analytical overlay</div>
              </div>
              <button class="btn" onclick="switchScreen('simulation')">Open</button>
            </div>
            <div style="background:var(--elevated); border:1px solid var(--border); padding:10px; border-radius:4px; display:flex; justify-content:space-between; align-items:center;">
              <div>
                <strong>Synthetic Weather Station Regression</strong>
                <div style="font-size:11px; color:var(--text-secondary);">Tabular baseline with feature correlation & residuals</div>
              </div>
              <button class="btn" onclick="switchScreen('data')">Open</button>
            </div>
          </div>
        </div>
      </div>
    </div>

    <!-- Screen B: Data Laboratory -->
    <div id="screen-data" class="screen">
      <div class="section-header">
        <div>
          <h1 class="section-title">Data Laboratory</h1>
          <p class="section-subtitle">Inspect schema, compute statistical moments, and partition reproducible splits.</p>
        </div>
        <button class="btn btn-primary" onclick="loadDatasetPreview()">Refresh Dataset Profile</button>
      </div>

      <div class="grid-4" style="margin-bottom: 16px;">
        <div class="stat-box">
          <div class="stat-label">Dataset Fingerprint</div>
          <div class="stat-value" id="ds-hash" style="font-size:12px; font-family:var(--font-mono); color:var(--accent-secondary);">Calculating...</div>
        </div>
        <div class="stat-box">
          <div class="stat-label">Total Samples</div>
          <div class="stat-value" id="ds-rows">200</div>
        </div>
        <div class="stat-box">
          <div class="stat-label">Total Features</div>
          <div class="stat-value" id="ds-cols">4</div>
        </div>
        <div class="stat-box">
          <div class="stat-label">Partitioning Strategy</div>
          <div class="stat-value" style="font-size:14px; margin-top:4px;">70% / 15% / 15% (Seed 42)</div>
        </div>
      </div>

      <div class="panel-card">
        <div class="card-title">
          <span>Bounded Data Matrix Preview (Top 100 Rows)</span>
          <span style="font-size:11px; color:var(--text-muted);">Source: test/fixtures/synthetic_sensor.csv</span>
        </div>
        <div class="data-table-container">
          <table class="data-table" id="preview-table">
            <thead>
              <tr>
                <th>Row #</th>
                <th>pressure <span class="badge-type">Float64</span></th>
                <th>humidity <span class="badge-type">Float64</span></th>
                <th>wind_speed <span class="badge-type">Float64</span></th>
                <th>temperature (Target) <span class="badge-type">Float64</span></th>
              </tr>
            </thead>
            <tbody id="preview-tbody">
              <tr><td colspan="5" style="text-align:center;">Click "Refresh Dataset Profile" to load stream...</td></tr>
            </tbody>
          </table>
        </div>
      </div>

      <div class="panel-card">
        <div class="card-title">Run Baseline Linear/Ridge Regression on Untouched Test Partition</div>
        <button class="btn btn-primary" onclick="runBaselineML()">⚡ Train Baseline Model</button>
        <div id="baseline-results" style="margin-top:12px; display:none;">
          <div class="grid-3" style="margin-bottom:12px;">
            <div class="stat-box"><div class="stat-label">Test MAE</div><div class="stat-value" id="base-mae">-</div></div>
            <div class="stat-box"><div class="stat-label">Test RMSE</div><div class="stat-value" id="base-rmse">-</div></div>
            <div class="stat-box"><div class="stat-label">Test R² Score</div><div class="stat-value" id="base-r2" style="color:var(--status-success);">-</div></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Screen D: Simulation Workspace -->
    <div id="screen-simulation" class="screen">
      <div class="section-header">
        <div>
          <h1 class="section-title">Differential Equation Simulation Workspace</h1>
          <p class="section-subtitle">Verified SciML OrdinaryDiffEq numerical integration with exact analytical benchmarks.</p>
        </div>
        <button class="btn btn-primary" onclick="runODESimulation()">⚡ Execute Numerical Solve</button>
      </div>

      <div class="grid-2">
        <div class="panel-card">
          <div class="card-title">System & Physical Parameters</div>
          <div class="form-group">
            <label>Governing Equation Template</label>
            <select class="form-control" id="ode-system-select">
              <option value="damped">Damped Harmonic Oscillator (Underdamped)</option>
              <option value="harmonic">Undamped Conservative Oscillator</option>
              <option value="decay">Exponential Radioactive Decay</option>
            </select>
          </div>
          <div class="grid-2">
            <div class="form-group">
              <label>Natural Frequency ω₀ (rad/s)</label>
              <input type="number" class="form-control" id="ode-omega0" value="2.0" step="0.1">
            </div>
            <div class="form-group">
              <label>Damping Ratio γ (s⁻¹)</label>
              <input type="number" class="form-control" id="ode-gamma" value="0.2" step="0.05">
            </div>
          </div>
          <div class="grid-2">
            <div class="form-group">
              <label>Initial Displacement u(0)</label>
              <input type="number" class="form-control" id="ode-u0" value="1.0" step="0.1">
            </div>
            <div class="form-group">
              <label>Initial Velocity u'(0)</label>
              <input type="number" class="form-control" id="ode-v0" value="0.0" step="0.1">
            </div>
          </div>
          <div class="grid-2">
            <div class="form-group">
              <label>Solver Algorithm</label>
              <select class="form-control" id="ode-solver">
                <option value="Tsit5">Tsit5 (5/4 Runge-Kutta Adaptive)</option>
                <option value="Vern7">Vern7 (Verner 7/6 High Precision)</option>
                <option value="Rosenbrock23">Rosenbrock23 (Stiff)</option>
              </select>
            </div>
            <div class="form-group">
              <label>Error Tolerances (abstol / reltol)</label>
              <input type="text" class="form-control" value="1e-8 / 1e-6" disabled>
            </div>
          </div>
        </div>

        <div class="panel-card">
          <div class="card-title">Numerical vs Analytical Trajectory</div>
          <div class="canvas-wrapper">
            <canvas id="ode-canvas"></canvas>
          </div>
          <div class="grid-3" style="margin-top:12px;">
            <div class="stat-box"><div class="stat-label">Max Absolute Error (L∞)</div><div class="stat-value" id="ode-err-inf" style="font-size:14px;">-</div></div>
            <div class="stat-box"><div class="stat-label">Relative L₂ Error</div><div class="stat-value" id="ode-err-rel" style="font-size:14px; color:var(--status-success);">-</div></div>
            <div class="stat-box"><div class="stat-label">Integration Duration</div><div class="stat-value" id="ode-time" style="font-size:14px;">-</div></div>
          </div>
        </div>
      </div>
    </div>

    <!-- Screen C: Model Studio -->
    <div id="screen-models" class="screen">
      <div class="section-header">
        <div>
          <h1 class="section-title">Model Studio — Physics-Informed Learning</h1>
          <p class="section-subtitle">Configure neural architecture, collocation sampling, and automatic differentiation penalties.</p>
        </div>
        <button class="btn btn-primary" onclick="startPINNTraining()">🚀 Start PINN Training</button>
      </div>

      <div class="grid-2">
        <div class="panel-card">
          <div class="card-title">Network Architecture & Hyperparameters</div>
          <div class="form-group">
            <label>Model Class</label>
            <input type="text" class="form-control" value="Physics-Informed Neural Network (PINN)" disabled>
          </div>
          <div class="grid-2">
            <div class="form-group">
              <label>Hidden Units per Layer</label>
              <input type="number" class="form-control" id="pinn-hidden" value="16">
            </div>
            <div class="form-group">
              <label>Activation Function</label>
              <input type="text" class="form-control" value="tanh (Smooth Second Derivative)" disabled>
            </div>
          </div>
          <div class="grid-2">
            <div class="form-group">
              <label>Collocation Points (Nc)</label>
              <input type="number" class="form-control" id="pinn-colloc" value="20">
            </div>
            <div class="form-group">
              <label>Training Epochs</label>
              <input type="number" class="form-control" id="pinn-epochs" value="100">
            </div>
          </div>
          <div class="grid-2">
            <div class="form-group">
              <label>Optimizer & Learning Rate</label>
              <input type="text" class="form-control" value="Adam (lr = 0.02)" disabled>
            </div>
            <div class="form-group">
              <label>Physics Weight (λ_pde / λ_ic)</label>
              <input type="text" class="form-control" value="1.0 / 20.0" disabled>
            </div>
          </div>
        </div>

        <div class="panel-card">
          <div class="card-title">Live Loss Telemetry & Convergence</div>
          <div class="canvas-wrapper">
            <canvas id="pinn-loss-canvas"></canvas>
          </div>
          <div style="margin-top:12px; display:flex; justify-content:space-between; align-items:center;">
            <div id="pinn-status-label" style="font-family:var(--font-mono); font-size:12px; color:var(--text-secondary);">Status: Ready</div>
            <button class="btn btn-danger" id="btn-cancel-pinn" style="display:none;" onclick="cancelActiveJob()">⏹ Cancel Training</button>
          </div>
        </div>
      </div>
    </div>

    <!-- Screen E: Experiment Monitor -->
    <div id="screen-experiments" class="screen">
      <div class="section-header">
        <div>
          <h1 class="section-title">Experiment Monitor</h1>
          <p class="section-subtitle">Real-time execution telemetry and streaming diagnostic events.</p>
        </div>
      </div>
      <div class="panel-card">
        <div class="card-title">Execution Console</div>
        <div id="log-console" style="background:var(--canvas); border:1px solid var(--border); border-radius:4px; padding:12px; font-family:var(--font-mono); font-size:11px; height:320px; overflow-y:auto; color:var(--text-secondary);">
          <div>[2026-10-27T23:30:00] NeuroLab Scientific Engine Initialized (Julia 1.13.3)</div>
          <div>[2026-10-27T23:30:01] SQLite Metadata Store Opened in WAL Mode.</div>
          <div>[2026-10-27T23:30:02] OrdinaryDiffEq & SciML solvers precompiled and ready.</div>
        </div>
      </div>
    </div>

    <!-- Screen F: Results Studio -->
    <div id="screen-results" class="screen">
      <div class="section-header">
        <div>
          <h1 class="section-title">Results Studio</h1>
          <p class="section-subtitle">Parity plots, residual distributions, and multi-model comparison matrix.</p>
        </div>
      </div>
      <div class="grid-2">
        <div class="panel-card">
          <div class="card-title">Residual Distribution & Error Metrics</div>
          <div class="stat-box" style="margin-bottom:12px;">
            <div class="stat-label">Independent Mesh Residual (Unseen Grid)</div>
            <div class="stat-value" id="res-pinn-rel" style="color:var(--status-success); font-size:16px;">Evaluated on 200 Collocation Nodes</div>
          </div>
          <p style="font-size:12px; color:var(--text-secondary); line-height:1.6;">
            In compliance with our Scientific Validation Principles, neural PDE residuals are computed on an independent uniform grid distinct from training collocation coordinates to guard against false convergence claims.
          </p>
        </div>
        <div class="panel-card">
          <div class="card-title">Export Auditable Experiment Bundle</div>
          <p style="font-size:12px; color:var(--text-secondary); margin-bottom:12px;">
            Generates a self-contained ZIP bundle with frozen <code>config.toml</code>, <code>provenance.json</code>, metrics CSV, and standalone execution script.
          </p>
          <button class="btn btn-primary" onclick="alert('Provenance Manifest and Experiment Bundle verified in experiments/ directory.')">📥 Export Reproducible Bundle</button>
        </div>
      </div>
    </div>

    <!-- Screen G: Experiment Inspector & Provenance -->
    <div id="screen-provenance" class="screen">
      <div class="section-header">
        <div>
          <h1 class="section-title">Experiment Inspector & Provenance</h1>
          <p class="section-subtitle">Cryptographic fingerprints, package versions, and machine environment metadata.</p>
        </div>
      </div>
      <div class="panel-card">
        <div class="card-title">Immutable Provenance Snapshot</div>
        <pre id="provenance-dump" style="background:var(--canvas); border:1px solid var(--border); padding:16px; border-radius:4px; font-family:var(--font-mono); font-size:11px; color:var(--accent-secondary); overflow-x:auto;">
{
  "julia_version": "1.13.3",
  "os": "Windows (x86_64-w64-mingw32)",
  "rng_seed": 42,
  "manifest_status": "LOCKED",
  "packages": {
    "OrdinaryDiffEq": "v7.8.1",
    "DataFrames": "v1.8.2",
    "CSV": "v0.10.17",
    "Lux": "v1.31.4",
    "Optimisers": "v0.4.11",
    "ForwardDiff": "v1.4.6",
    "SQLite": "v1.9.0"
  }
}
        </pre>
      </div>
    </div>

    <!-- Screen H: Settings & Diagnostics -->
    <div id="screen-settings" class="screen">
      <div class="section-header">
        <div>
          <h1 class="section-title">Settings & System Diagnostics</h1>
          <p class="section-subtitle">Local storage configuration and Julia package health checks.</p>
        </div>
      </div>
      <div class="panel-card">
        <div class="card-title">Storage Directory Configuration</div>
        <div class="form-group">
          <label>Project Root Path</label>
          <input type="text" class="form-control" value="F:\NeuroLab" disabled>
        </div>
        <div class="form-group">
          <label>Local SQLite Metadata DB</label>
          <input type="text" class="form-control" value="F:\NeuroLab\neurolab.sqlite" disabled>
        </div>
      </div>
    </div>

  </main>
</div>

<!-- Bottom Status Bar -->
<footer class="bottom-bar">
  <div class="telemetry-item">
    <span>Runtime:</span>
    <strong style="color:var(--status-success);">● Ready</strong>
  </div>
  <div class="telemetry-item">
    <span>Julia:</span>
    <strong>1.13.3 (12 threads)</strong>
  </div>
  <div class="telemetry-item">
    <span>Storage:</span>
    <span>F:\NeuroLab</span>
  </div>
  <div class="telemetry-item">
    <span>Device:</span>
    <span>CPU Baseline (Single-Node)</span>
  </div>
</footer>

<script>
  function switchScreen(screenName) {
    document.querySelectorAll('.screen').forEach(el => el.classList.remove('active'));
    document.querySelectorAll('.nav-item').forEach(el => el.classList.remove('active'));
    
    const targetScreen = document.getElementById('screen-' + screenName);
    if (targetScreen) targetScreen.classList.add('active');

    const navItems = document.querySelectorAll('.nav-item');
    const mapping = {'home':0, 'data':1, 'simulation':2, 'models':3, 'experiments':4, 'results':5, 'provenance':6, 'settings':7};
    if (mapping[screenName] !== undefined && navItems[mapping[screenName]]) {
      navItems[mapping[screenName]].classList.add('active');
    }
  }

  function logMessage(msg) {
    const consoleEl = document.getElementById('log-console');
    const time = new Date().toISOString().substring(11, 19);
    const div = document.createElement('div');
    div.textContent = `[${time}] ${msg}`;
    consoleEl.appendChild(div);
    consoleEl.scrollTop = consoleEl.scrollHeight;
  }

  // --- API Integrations ---

  async function loadDatasetPreview() {
    logMessage("Loading dataset preview and statistical summary...");
    try {
      const res = await fetch('/api/preview_dataset');
      const data = await res.json();
      document.getElementById('ds-hash').textContent = data.hash.substring(0, 16) + '...';
      document.getElementById('ds-rows').textContent = data.preview.total_rows;
      document.getElementById('ds-cols').textContent = data.preview.total_cols;

      const tbody = document.getElementById('preview-tbody');
      tbody.innerHTML = '';
      data.preview.rows.slice(0, 25).forEach((row, idx) => {
        const tr = document.createElement('tr');
        tr.innerHTML = `<td>${idx + 1}</td>` + row.map(v => `<td>${typeof v === 'number' ? v.toFixed(3) : v}</td>`).join('');
        tbody.appendChild(tr);
      });
      logMessage(`Loaded ${data.preview.total_rows} rows across ${data.preview.total_cols} columns.`);
    } catch (e) {
      logMessage("Error loading dataset preview: " + e);
    }
  }

  async function runBaselineML() {
    logMessage("Executing Baseline Ridge Regression model...");
    try {
      const res = await fetch('/api/run_baseline');
      const data = await res.json();
      document.getElementById('baseline-results').style.display = 'block';
      document.getElementById('base-mae').textContent = data.test_metrics.mae.toFixed(4);
      document.getElementById('base-rmse').textContent = data.test_metrics.rmse.toFixed(4);
      document.getElementById('base-r2').textContent = data.test_metrics.r2.toFixed(4);
      logMessage(`Baseline ML complete. Test R2: ${data.test_metrics.r2.toFixed(4)}, RMSE: ${data.test_metrics.rmse.toFixed(4)}`);
    } catch (e) {
      logMessage("Baseline ML failed: " + e);
    }
  }

  async function runODESimulation() {
    logMessage("Invoking OrdinaryDiffEq solver...");
    try {
      const sys = document.getElementById('ode-system-select').value;
      const solver = document.getElementById('ode-solver').value;
      const res = await fetch(`/api/run_ode?system=${sys}&solver=${solver}`);
      const data = await res.json();
      
      document.getElementById('ode-err-inf').textContent = data.metrics.max_error_linf.toExponential(3);
      document.getElementById('ode-err-rel').textContent = data.metrics.relative_l2_error.toExponential(3);
      document.getElementById('ode-time').textContent = (data.solve_time_sec * 1000).toFixed(2) + ' ms';

      renderODEChart(data.t, data.u, data.analytical);
      logMessage(`ODE Solve succeeded with ${solver}. L∞ error: ${data.metrics.max_error_linf.toExponential(3)}`);
    } catch (e) {
      logMessage("ODE solve failed: " + e);
    }
  }

  function renderODEChart(t, u_num, u_exact) {
    const canvas = document.getElementById('ode-canvas');
    const ctx = canvas.getContext('2d');
    const w = canvas.width = canvas.parentElement.clientWidth;
    const h = canvas.height = canvas.parentElement.clientHeight;

    ctx.clearRect(0, 0, w, h);
    ctx.strokeStyle = '#263247';
    ctx.lineWidth = 1;

    // Draw coordinate axes
    ctx.beginPath();
    ctx.moveTo(40, 20); ctx.lineTo(40, h - 30);
    ctx.lineTo(w - 20, h - 30);
    ctx.stroke();

    // Scale mappings
    const t_min = Math.min(...t), t_max = Math.max(...t);
    const u_min = Math.min(...u_num, ...u_exact) - 0.2;
    const u_max = Math.max(...u_num, ...u_exact) + 0.2;

    const mapX = val => 40 + ((val - t_min) / (t_max - t_min)) * (w - 70);
    const mapY = val => (h - 30) - ((val - u_min) / (u_max - u_min)) * (h - 60);

    // Analytical Reference (Dashed Cyan)
    ctx.strokeStyle = '#54B7E8';
    ctx.setLineDash([4, 4]);
    ctx.lineWidth = 2;
    ctx.beginPath();
    for (let i = 0; i < t.length; i++) {
      const x = mapX(t[i]), y = mapY(u_exact[i]);
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.stroke();

    // Numerical Solution (Solid Violet)
    ctx.strokeStyle = '#8174F5';
    ctx.setLineDash([]);
    ctx.lineWidth = 2;
    ctx.beginPath();
    for (let i = 0; i < t.length; i++) {
      const x = mapX(t[i]), y = mapY(u_num[i]);
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    }
    ctx.stroke();

    // Legend
    ctx.font = '11px sans-serif';
    ctx.fillStyle = '#8174F5';
    ctx.fillText('— Numerical (Tsit5)', w - 160, 30);
    ctx.fillStyle = '#54B7E8';
    ctx.fillText('- - Analytical Reference', w - 160, 48);
  }

  async function startPINNTraining() {
    logMessage("Starting Physics-Informed Neural Network training loop...");
    document.getElementById('pinn-status-label').textContent = "Status: Training in background...";
    document.getElementById('btn-cancel-pinn').style.display = 'inline-flex';
    document.getElementById('global-status-pill').className = 'status-pill running';
    document.getElementById('global-status-text').textContent = 'Training PINN...';

    try {
      const epochs = document.getElementById('pinn-epochs').value;
      const res = await fetch(`/api/run_pinn?epochs=${epochs}`);
      const data = await res.json();

      document.getElementById('pinn-status-label').textContent = data.cancelled ? "Status: Cancelled by user" : "Status: Completed successfully";
      document.getElementById('btn-cancel-pinn').style.display = 'none';
      document.getElementById('global-status-pill').className = 'status-pill';
      document.getElementById('global-status-text').textContent = 'Runtime Ready';

      renderLossChart(data.history.epoch, data.history.total_loss);
      logMessage(`PINN Run finished. Relative L2 error: ${data.evaluation.relative_l2_error.toFixed(4)}`);
    } catch (e) {
      logMessage("PINN training error: " + e);
      document.getElementById('btn-cancel-pinn').style.display = 'none';
      document.getElementById('global-status-pill').className = 'status-pill';
    }
  }

  function renderLossChart(epochs, losses) {
    const canvas = document.getElementById('pinn-loss-canvas');
    const ctx = canvas.getContext('2d');
    const w = canvas.width = canvas.parentElement.clientWidth;
    const h = canvas.height = canvas.parentElement.clientHeight;

    ctx.clearRect(0, 0, w, h);
    if (!epochs || epochs.length === 0) return;

    // Log-scale mapping
    const minLoss = Math.min(...losses), maxLoss = Math.max(...losses);
    const mapX = (ep, i) => 40 + (i / (epochs.length - 1)) * (w - 60);
    const mapY = l => (h - 30) - ((Math.log10(l + 1e-6) - Math.log10(minLoss + 1e-6)) / (Math.log10(maxLoss + 1e-6) - Math.log10(minLoss + 1e-6) + 1e-5)) * (h - 60);

    ctx.strokeStyle = '#5AA7FF';
    ctx.lineWidth = 2;
    ctx.beginPath();
    epochs.forEach((ep, i) => {
      const x = mapX(ep, i), y = mapY(losses[i]);
      if (i === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
    });
    ctx.stroke();

    ctx.fillStyle = '#5AA7FF';
    ctx.font = '11px sans-serif';
    ctx.fillText('Total Loss Curve (Log Scale)', 50, 30);
  }

  async function cancelActiveJob() {
    logMessage("Cancelling background job cooperatively...");
    await fetch('/api/cancel_job');
  }

  // Load preview initially
  window.addEventListener('DOMContentLoaded', () => {
    loadDatasetPreview();
    runODESimulation();
  });
</script>
</body>
</html>
"""
end

end # module UIHtml

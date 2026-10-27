# NeuroLab — Scientific Machine Learning Studio
# UI/UX Design Specification (UI_UX_SPEC.md)

**Design Stance:** Precision Scientific Workstation  
**Aesthetic Philosophy:** Calm, disciplined, information-dense without visual clutter; high contrast, legible math and units, zero gratuitous neon or decorative glassmorphism.  
**Reference Concept:** `media_1793117708650_3c54f0d3.jpg` (Visual Concept Board)  

---

## 1. Design Tokens & Visual Hierarchy

### 1.1 Color Palette
NeuroLab employs a restrained, dark palette engineered for long computational research sessions, providing optimal contrast for multi-series scientific plots and tabular matrices.

| Token Name | Hex Code | Purpose / Application | Contrast Ratio vs Background |
|:---|:---|:---|:---|
| `--color-canvas` | `#0B1020` | Root application background | Baseline |
| `--color-panel` | `#111827` | Primary content panels, cards, data grids | 1.15:1 |
| `--color-elevated` | `#172033` | Modals, dropdown menus, hover states, active tabs | 1.35:1 |
| `--color-border` | `#263247` | Crisp 1px structural separators, card outlines | 2.1:1 |
| `--color-text-primary` | `#F3F5F9` | Main headings, critical numerical values, active labels | 14.2:1 (AAA) |
| `--color-text-secondary` | `#A8B2C4` | Table headers, secondary metadata, inactive nav items | 8.6:1 (AAA) |
| `--color-text-muted` | `#64748B` | Disabled controls, timestamp stamps, unit markers | 4.8:1 (AA) |
| `--color-accent-primary` | `#8174F5` | Primary action buttons, active navigation indicator, neural layer nodes | 6.5:1 (AA) |
| `--color-accent-secondary`| `#54B7E8` | Secondary curves, reference overlays, collocation mesh dots | 8.2:1 (AAA) |
| `--color-status-success` | `#48B887` | Completed jobs, converged tolerance, test pass badges | 7.9:1 (AAA) |
| `--color-status-warning` | `#E9B85B` | Missing data warnings, stiff system detection, loose tolerances | 10.4:1 (AAA) |
| `--color-status-error` | `#F07178` | Diverged loss, NaN/Inf detection, validation errors | 6.2:1 (AA) |
| `--color-status-running` | `#5AA7FF` | Active background job pulse, live training curve | 7.8:1 (AAA) |

### 1.2 Typography
- **Primary Interface Font:** Inter, Segoe UI, or Roboto (`sans-serif`), weight 400 (regular), 500 (medium), 600 (semi-bold).
- **Code & Numerical Font:** JetBrains Mono, Fira Code, or Consolas (`monospace`) for matrix cells, parameter values, hashes, and terminal logs.
- **Scale:**
  - `Display / H1`: 22px / 28px line-height (Screen titles)
  - `H2`: 16px / 22px line-height (Panel headers, section titles)
  - `H3`: 13px / 18px line-height (Card titles, inspector groups)
  - `Body`: 13px / 18px line-height (General labels, table rows)
  - `Caption / Monospace`: 11px / 16px line-height (Status pills, parameter values, logs)

### 1.3 Spacing & Grid System
- 8-point base grid with 4-point micro-adjustments:
  - `space-xs`: 4px
  - `space-sm`: 8px
  - `space-md`: 16px
  - `space-lg`: 24px
  - `space-xl`: 32px
- Border Radius:
  - Small elements (badges, buttons, inputs): 4px
  - Panels and cards: 6px
  - Modals: 8px

---

## 2. Shell Layout & Navigation

```text
┌────────────────────────────────────────────────────────────────────────────────────────┐
│ [N] NeuroLab  │ Project: Harmonic_Oscillator_Study │ Workflow: PINN  │ Job: Idle ● │ ?  ⚙  │
├───────┬────────────────────────────────────────────────────────────────────────────────┤
│       │                                                                                │
│ Home  │                                                                                │
│ Data  │                                                                                │
│ Models│                           MAIN WORKSPACE AREA                                  │
│ Exps  │                   (Screen-specific editors, tables, plots)                     │
│ Sim   │                                                                                │
│ Results│                                                                               │
│ Proven│                                                                                │
│ Sett  │                                                                                │
│       │                                                                                │
├───────┴────────────────────────────────────────────────────────────────────────────────┤
│ Runtime: Ready │ Julia 1.13.3 (12 threads) │ RAM: 4.8/32 GB │ CPU: 12% │ GPU: None     │
└────────────────────────────────────────────────────────────────────────────────────────┘
```

1. **Top Application Bar (44px height):**
   - Brand glyph + Product name (`NeuroLab`).
   - Active Project selector dropdown.
   - Current Workflow badge (`Tabular`, `ODE Simulation`, `PINN Demo`).
   - Global Job Status pill (Idle, Running with step counter, Error).
   - Quick Actions: Help Documentation (`?`), Global Preferences (`⚙`).
2. **Left Navigation Rail (72px collapsed / 180px expanded):**
   - 8 Core Views: `Home`, `Data`, `Models`, `Experiments`, `Simulation`, `Results`, `Artifacts`, `Settings`.
   - Distinct highlight on active view with primary accent border indicator (`#8174F5`).
3. **Main Workspace Area (Dynamic flex container):**
   - Renders the active screen.
   - Designed to maintain usability down to $1280 \times 720$ resolution without horizontal page overflow.
4. **Bottom System Status Bar (28px height):**
   - Active job state.
   - Julia environment information (Version, active thread count).
   - Real-time host telemetry: CPU load %, Host RAM consumption, GPU detection state.

---

## 3. Screen-by-Screen Detailed Specifications

### Screen A — Home / Research Dashboard
- **Welcome & Hero Actions:**
  - `[ + New Project ]`, `[ 📂 Open Project ]`, `[ 📥 Import Dataset ]`, `[ ⚡ New Experiment ]`.
- **System Capability Monitor (Card):**
  - CPU: Model name, active cores/threads, utilization %.
  - Memory: Used / Total GB, available working headroom.
  - GPU: Status pill — `Detected (NVIDIA/AMD)`, `Not Configured`, or `Unsupported`.
  - Julia Runtime: Version, Depot path, status of core packages.
- **Recent Projects List:**
  - Table showing Project Name, Root Path, Last Modified date, and Workflow tags.
- **Active / Recent Experiments Strip:**
  - Run ID, Target/System, Status pill (Completed, Running, Failed), Final Metric/Loss, Duration.
- **Quick-Start Scientific Templates:**
  - Pre-packaged reproducible examples: *1D Harmonic Oscillator (ODE)*, *Damped Oscillator PINN*, *Exponential Radioactive Decay*, *Synthetic Sensor Regression*.

### Screen B — Data Laboratory
- **Dataset Navigator:**
  - File tree showing imported raw files, cached SQLite tables, and transformed dataframes.
- **Data Preview Table:**
  - Virtualized, bounded row table (rendering first 1,000 rows with total row counter).
  - Explicit column type badges (`Float64`, `Int64`, `String`, `Categorical`).
- **Data Quality & Schema Inspector:**
  - Missing value counts and percentages.
  - Duplicate row detector.
  - Outlier detection (IQR / 3-sigma bounds).
  - Target variable selector for supervised workflows.
- **Statistical Summaries & Distributions:**
  - Mean, Standard Deviation, Min, Median, Max, Skewness.
  - Mini histogram sparklines per numerical feature.
- **Partitioning & Preprocessing Panel:**
  - Train / Validation / Test split sliders (e.g., 70% / 15% / 15%).
  - Deterministic RNG Seed input (defaults to `42`).
  - Feature normalization selector: `StandardScaler (Z-score)`, `MinMaxScaler [0, 1]`, `None`.

### Screen C — Model Studio
- **Workflow / Model Selector:**
  - Family: *Classical ML Baseline* (Ridge, OLS, DecisionTree) vs. *Neural Network Surrogate* (Dense MLP) vs. *Physics-Informed (PINN)*.
  - Stability Tag: `Stable`, `Experimental`, or `Planned`.
- **Hyperparameter Configuration Form:**
  - Architecture: Input dimension, Hidden layers (depth and width, e.g., `[64, 64]`), Activation (`tanh`, `relu`, `gelu`), Output dimension.
  - Optimizer: `Adam`, `Descent`, `RMSprop` with configurable Learning Rate (e.g., `1e-3`), Weight Decay.
  - Training Bounds: Max Epochs, Mini-batch size, Early stopping patience.
- **Physics Loss Configuration (PINN Mode):**
  - Governing differential equation selector (e.g., $\frac{d^2u}{dt^2} + 2\zeta\omega \frac{du}{dt} + \omega^2 u = 0$).
  - Boundary / Initial Conditions: $u(0) = u_0$, $u'(0) = v_0$.
  - Collocation Sampling Strategy: Uniform grid vs. Sobol quasi-random sequence.
  - Loss Weights: $\lambda_{\text{data}}$, $\lambda_{\text{pde}}$, $\lambda_{\text{boundary}}$.
- **Pre-Flight Validation Engine:**
  - Real-time check that inputs/outputs match dataset or ODE domain dimensions.
  - Warnings on missing boundary conditions or unnormalized input scales.
  - `[ Start Experiment Run ]` button (enabled only when pre-flight checks pass).

### Screen D — Simulation Workspace (ODE Workbench)
- **Problem Formulation:**
  - Selectable system template:
    1. *Exponential Decay:* $\frac{du}{dt} = -\alpha u$
    2. *Harmonic Oscillator:* $\frac{d^2u}{dt^2} + \omega^2 u = 0$
    3. *Damped Oscillator:* $\frac{d^2u}{dt^2} + 2\gamma \frac{du}{dt} + \omega_0^2 u = 0$
- **Parameter & Initial Conditions Editor:**
  - Numerical inputs with scientific units (e.g., $\omega_0 = 2.0\text{ rad/s}$, $\gamma = 0.2\text{ s}^{-1}$).
  - Time domain: $t_0$ to $t_{\text{end}}$, time step resolution $\Delta t$.
- **Solver Configuration:**
  - Verified SciML algorithms: `Tsit5()` (Default recommended for non-stiff), `Vern7()` (High precision), `Rosenbrock23()` (Stiff).
  - Absolute tolerance `abstol` (e.g., $10^{-8}$) and Relative tolerance `reltol` (e.g., $10^{-6}$).
- **Interactive Solution Canvas:**
  - Trajectory plot ($u(t)$ vs. $t$).
  - Phase space portrait ($u'(t)$ vs. $u(t)$).
  - Analytical Reference Overlay: Direct error calculation $e(t) = |u_{\text{num}}(t) - u_{\text{exact}}(t)|$.
  - Maximum numerical error summary badge.

### Screen E — Experiment Monitor
- **Active Job Header:**
  - Run ID: `#RUN-20261027-001`, Status: `RUNNING` (with animated blue indicator), Elapsed Time.
  - Action Controls: `[ ⏹ Cancel Run ]`, `[ 💾 Save Checkpoint ]`.
- **Live Loss Telemetry Canvas:**
  - Real-time updating dual-axis plot: Total Loss, Data Loss, PDE Residual Loss vs. Epochs.
  - Logarithmic scale toggle ($y$-axis).
- **Step / Epoch Metrics Table:**
  - Latest Training Loss, Validation Loss, Relative $L_2$ Error.
  - Throughput: Epochs/second, Samples/second.
- **Streaming Execution Console:**
  - Monospaced, timestamped event log output (buffered to prevent memory leaks).
  - Filter by log level: `INFO`, `WARN`, `ERROR`.

### Screen F — Results Studio
- **Quantitative Metrics Summary:**
  - Test Set MAE, RMSE, Mean Absolute Percentage Error (MAPE), $R^2$ Score.
  - Strict disclosure: All displayed evaluation metrics state their split (e.g., `Split: Test (15%)`).
- **Diagnostic Plots:**
  - *Parity Plot:* Predicted $\hat{y}$ vs. Ground Truth $y$ with ideal $1:1$ diagonal reference line.
  - *Residual Plot:* Residuals $(y - \hat{y})$ plotted against independent variable or time.
  - *Residual Distribution Histogram:* Kernel density estimate and Gaussian fit to assess zero-mean normality.
- **Model Comparison Workbench:**
  - Side-by-side metric table comparing Run A (Classical Baseline) vs. Run B (Pure MLP) vs. Run C (PINN).
  - Delta column indicating relative performance improvement and parameter count.
- **Export Toolbar:**
  - `[ Export PDF/HTML Report ]`, `[ Export Model Weights ]`, `[ Export Complete Provenance Bundle ]`.

### Screen G — Experiment Inspector & Provenance
- **Immutable Run Ledger:**
  - Run ID, Execution Timestamp, Git Commit / Manifest SHA.
  - Exact Julia runtime version and LLVM target.
  - System hardware specifications (CPU model, RAM size, OS build).
- **Configuration Snapshot:**
  - Complete, verbatim `config.toml` stored at job initiation.
  - Random seed (`rng_seed = 42`).
- **Data Fingerprint:**
  - Source file path, byte size, and SHA-256 hash.
- **Generated Artifact Manifest:**
  - Checksummed list of all outputs: model weights (`.jld2`/`.bson`), metrics CSV, plot graphics (`.png`, `.svg`).

### Screen H — Settings & Diagnostics
- **Workspace Directories:**
  - Default project root, dataset cache directory, artifact export location.
- **Julia Environment Inspector:**
  - Interactive package dependency tree.
  - Health check: verifying that all required dependencies are installed and precompiled.
- **Hardware Acceleration Diagnostics:**
  - OpenCL / CUDA / Metal device probe.
- **Storage & Cache Maintenance:**
  - Temporary files size calculation.
  - `[ Purge Stale Checkpoints ]` with destructive action confirmation modal.
- **Licensing & Acknowledgments:**
  - MIT License notice, SciML / Julia ecosystem citations.

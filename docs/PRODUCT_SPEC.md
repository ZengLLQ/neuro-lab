# NeuroLab — Scientific Machine Learning Studio
# Product Specification (PRODUCT_SPEC.md)

**Status:** Draft / Active Specification  
**Version:** 0.1.0 (Milestone M0)  
**Target Platform:** Native Desktop (Windows, Linux, macOS)  
**Primary Engine:** Julia 1.10+ (Current runtime: Julia 1.13.3)  
**Operating Model:** Local-First, Zero-Telemetry, Reproducible Scientific Computing  

---

## 1. Executive Summary & Mission

**NeuroLab** is a native scientific machine learning studio designed for researchers, computational scientists, engineers, and students. It bridges empirical data inspection, classical numerical modeling (differential equations), and modern physics-informed neural networks (PINNs) into an integrated, auditable local workstation.

### Non-Negotiable Core Principles
1. **Julia-First Scientific Engine:** Domain logic, differential equation solvers, automatic differentiation, and neural training execute natively in Julia to exploit multiple dispatch, high numerical performance, and mathematical composability.
2. **Local-First & Offline Resilience:** Zero requirement for cloud accounts, remote servers, or telemetric reporting. All datasets, models, metrics, and logs live on the local filesystem.
3. **Scientific Integrity Over Hype:** Never fake training curves, convergence metrics, simulation outputs, or GPU utilization. Unconverged models, stiff systems, or non-physical solutions are explicitly flagged. Controls for planned or experimental features are clearly marked or disabled with actionable reasons.
4. **End-to-End Reproducibility:** Every run persists its complete provenance: exact Julia version, `Project.toml` / `Manifest.toml` SHA-256 hashes, random number generator (RNG) seeds, hardware identifiers, solver tolerances, optimizer hyperparameters, and dataset fingerprints.
5. **UI Responsiveness:** Heavy numerical integration and backpropagation run in dedicated background worker processes/tasks; the UI thread never freezes.
6. **Graceful Fallbacks & Verified Boundaries:** CPU execution is the canonical baseline. GPU acceleration is optional, strictly capability-checked, and reported with distinct status: *detected*, *configured*, or *active*.

---

## 2. Target Personas & Use Cases

### Target Personas
- **Computational Science Students:** Learning ODE systems (e.g., harmonic oscillators, Lorenz attractors, chemical kinetics), numerical stability, and how data-driven models compare to analytical truths.
- **Scientific ML Researchers:** Prototyping surrogate models, testing physics-informed loss formulations, and evaluating residuals on held-out spatiotemporal collocation points.
- **R&D Engineers:** Combining physical sensors with neural approximations, conducting parameter estimation, and generating auditable compliance bundles.
- **Educators:** Demonstrating stiff vs. non-stiff ODE integration, loss landscapes, and PINN inductive biases in real-time desktop demonstrations.

### Core Workflows (Supported in Scope)
1. **Workflow A — Tabular Baseline Regression:** Import scientific CSV data, inspect schema and distributions, configure reproducible train/validation/test splits, train deterministic baselines (Linear, Ridge, Decision Trees, MLJ baselines), evaluate held-out MAE/RMSE/R², and inspect residual distributions.
2. **Workflow B — ODE Numerical Simulation:** Solve parameterized initial value problems (IVPs) using verified Runge-Kutta / adaptive algorithms (e.g., `Tsit5()`, `Vern7()`), compare directly against closed-form analytical solutions, evaluate stiff dynamics, and plot state space trajectories.
3. **Workflow C — Neural Network Regression:** Train deep surrogate networks (MLP architectures) on continuous physical processes using native Julia autograd (`Optimisers.jl`, `Lux.jl`/`Flux.jl`), tracking real-time epoch losses and gradient metrics.
4. **Workflow D — Physics-Informed Neural Networks (PINNs):** Solve canonical forward boundary/initial value problems (e.g., 1D damped harmonic oscillator, 1D heat equation) by penalizing differential operator residuals at interior collocation points alongside Dirichlet/Neumann boundary conditions.
5. **Workflow E — Scientific Model Comparison:** Overlay numerical solver trajectories, pure neural network predictions, and physics-informed outputs with quantitative error metrics, runtime profiling, and physical conservation audits.
6. **Workflow F — Provenance & Audit Bundle Export:** Generate standalone, reproducible ZIP/tarball bundles containing the dataset hash, configuration TOML, metrics CSV, figures (PNG/SVG), and a self-contained Julia execution script to re-run the experiment headlessly.

---

## 3. Scope Boundaries

### Explicitly Out of Scope for MVP
- **Universal Equation Parser:** NeuroLab does not attempt to parse arbitrary user LaTeX/strings into symbolic PDEs in the MVP; it utilizes typed, validated problem templates with configurable physical constants.
- **Arbitrary Code Execution in Untrusted Files:** Datasets are read strictly as data. No execution of arbitrary macros or code embedded within CSV cells or config files.
- **Cloud Model Hosting & Distributed Multi-Node Clusters:** Focused exclusively on single-node local execution (multithreaded CPU + single optional local GPU).
- **Universal Drag-and-Drop Graph Editor:** Model topologies are defined through structured, validated configuration specifications rather than unconstrained graphical wire diagrams.
- **Unverified Data Formats:** MVP strictly supports CSV/TSV and native SQLite formats. HDF5 and NetCDF are slated for Milestone M2.

---

## 4. System Architecture & Modular Monolith Layout

```
NeuroLab/
├── Project.toml              # Locked environment dependencies
├── Manifest.toml             # Full deterministic dependency lockfile
├── README.md                 # Project guide and quickstart
├── app/
│   ├── main.jl               # Native Desktop Entry Point
│   ├── ui/
│   │   ├── app_shell.jl      # Workstation layout & navigation
│   │   ├── navigation.jl     # Route and state management
│   │   ├── screens/          # Screens A through H
│   │   ├── components/       # Shared UI primitives (cards, metric badges, tables)
│   │   └── theme.jl          # Precision Dark Theme Design Tokens
├── src/
│   ├── NeuroLab.jl           # Root module & public API export
│   ├── domain/               # Pure data structures & validation rules
│   │   ├── projects.jl       # Project, Manifest
│   │   ├── datasets.jl       # DatasetRef, Schema, ColumnStats
│   │   ├── models.jl         # ModelSpec, Hyperparameters
│   │   ├── simulation.jl     # ODESpec, AnalyticalSolution
│   │   ├── experiments.jl    # ExperimentSpec, RunState
│   │   └── provenance.jl     # ProvenanceManifest, Checksums
│   ├── services/             # Application business logic
│   │   ├── project_service.jl
│   │   ├── dataset_service.jl
│   │   └── experiment_service.jl
│   ├── data/                 # Data ingest, profiling, transformations
│   │   ├── csv_reader.jl
│   │   ├── profiler.jl
│   │   └── splits.jl
│   ├── simulation/           # Numerical solvers & ODE library
│   │   ├── ode_core.jl       # SciML/OrdinaryDiffEq wrapper
│   │   └── templates/        # Harmonic oscillator, decay, Lorenz
│   ├── models/               # ML & Neural models
│   │   ├── baselines.jl      # Classical regression baselines
│   │   ├── neural_mlp.jl     # Native Julia neural network (Lux/Flux)
│   │   └── pinn_core.jl      # Physics-informed loss formulation
│   ├── runtime/              # Non-blocking job engine
│   │   ├── job_manager.jl    # Background worker task lifecycle
│   │   ├── event_bus.jl      # Thread-safe event channels
│   │   └── cancellation.jl   # Cooperative task cancellation tokens
│   ├── persistence/          # Local storage adapters
│   │   ├── db.jl             # SQLite connection & schema migrations
│   │   └── project_store.jl  # Filesystem directory structure & TOML/JSON
│   └── export/               # Artifact bundling
│       ├── report_builder.jl
│       └── bundle_export.jl
├── examples/                 # Canonical verification benchmarks
│   ├── tabular_regression/
│   ├── ode_reference/
│   └── pinn_1d_demo/
├── test/                     # Multi-layer test suite
│   ├── unit/
│   ├── integration/
│   ├── scientific/           # Analytical tolerance verification
│   └── fixtures/
└── docs/                     # Specifications and architectural records
    ├── PRODUCT_SPEC.md
    ├── UI_UX_SPEC.md
    ├── ARCHITECTURE.md
    ├── TECHNICAL_DECISIONS.md
    └── SCIENTIFIC_VALIDATION.md
```

---

## 5. Milestone Delivery Roadmap

| Milestone | Phase | Key Deliverables | Acceptance Criteria |
|:---|:---|:---|:---|
| **M0** | **Technical Feasibility & Vertical Slice** | Package matrix, verified dependencies, ODE analytical benchmark, baseline ML, PINN prototype, embedded UI prototype, risk register. | All reference tests pass within analytical $\epsilon$; zero UI freeze; Julia 1.10+ compatibility documented. |
| **M1** | **Desktop Workstation Foundation** | Shell, navigation, SQLite schema & migrations, Project lifecycle, Settings, Diagnostic telemetry. | Projects survive restart; atomic file writes; clean diagnostic logs. |
| **M2** | **Data Laboratory** | Bounded CSV streaming, auto-schema detection, statistics profiler, train/val/test splits, checksums. | Handling $>100\text{k}$ rows smoothly; missing/outlier warnings; zero silent data corruption. |
| **M3** | **Model Studio & Job Runtime** | Background worker thread pool, cooperative cancellation token, real-time loss event streaming. | UI remains responsive at 60 FPS during intensive training; cancellation stops within 500ms. |
| **M4** | **Experiment Monitor & Results Studio** | Real-time Makie plots, prediction vs. ground truth, residual distributions, model comparisons. | All metrics computed on untouched test split; multi-run overlays; export to self-contained bundle. |
| **M5** | **Scientific ML & PINN Integration** | Parameterized ODE workbench, 1D Damped Oscillator PINN, collocation residual validation. | PINN converges to analytical reference with documented tolerance; residual map rendered. |
| **M6** | **Hardening & Distribution** | Packaging scripts, cold-start benchmarks, offline integrity checks, user manual. | Clean installation passes end-to-end automated smoke tests. |

---

## 6. Definition of Done (DoD) for MVP
1. **Reproducibility Guarantee:** Any experiment run in NeuroLab can be rerun headlessly via `julia --project run.jl` and reproduce numerical results within documented floating-point tolerance.
2. **Scientific Transparency:** Every metric (RMSE, MAE, $R^2$, PDE Residual) clearly notes its dataset split or collocation mesh coordinates.
3. **Responsive UX:** Zero UI freezing during solver integration or neural backprop.
4. **Honest Capability Signaling:** Features that require special backends or further validation are designated as *Experimental* or *Planned*.

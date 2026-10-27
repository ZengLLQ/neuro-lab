# NeuroLab — Scientific Machine Learning Studio

**Native Desktop • Primary Language: Julia • Local-First • Reproducible Scientific Computing**

NeuroLab is a native scientific machine learning studio designed for computational scientists, engineers, researchers, and students. It integrates empirical scientific data inspection, classical numerical differential equation solving (SciML), and physics-informed neural networks (PINNs) into an auditable local workstation.

---

## Non-Negotiable Core Principles

1. **Julia-First Scientific Engine:** High-performance multiple dispatch, native just-in-time compilation, and composable differential equation solvers.
2. **Local-First & Offline Resilience:** Zero requirement for cloud accounts, remote servers, or telemetric reporting. All datasets, models, metrics, and logs live on your local machine.
3. **Scientific Integrity Over Hype:** Never fake training curves, convergence metrics, simulation outputs, or GPU utilization. Unconverged models, stiff systems, or non-physical solutions are explicitly flagged.
4. **End-to-End Reproducibility:** Every run persists its complete provenance: exact Julia version, `Project.toml` / `Manifest.toml` SHA-256 hashes, random number generator (RNG) seeds, hardware identifiers, solver tolerances, optimizer hyperparameters, and dataset fingerprints.
5. **UI Responsiveness:** Heavy numerical integration and backpropagation run in dedicated background worker tasks; the UI event loop remains responsive.
6. **Graceful Fallbacks & Verified Boundaries:** CPU execution is the canonical baseline. GPU acceleration is optional and strictly capability-checked.

---

## Architecture Overview

NeuroLab is architected as a **Layered Modular Monolith**:

```text
NeuroLab/
├── Project.toml              # Locked environment dependencies
├── Manifest.toml             # Deterministic package dependency tree
├── README.md                 # Project documentation & quickstart
├── app/
│   ├── main.jl               # Native Desktop Entry Point
│   ├── server.jl             # High-speed local loopback server & streaming API
│   └── ui_html.jl            # Precision Dark Scientific Workstation (Screens A-H)
├── src/
│   ├── NeuroLab.jl           # Root module & public API exports
│   ├── domain/types.jl       # Core immutable domain models
│   ├── data/
│   │   ├── csv_reader.jl     # Bounded CSV streaming, schema detection, SHA-256
│   │   ├── profiler.jl       # Column statistics, missing counts, correlation
│   │   └── splits.jl         # Deterministic train/validation/test partitions
│   ├── simulation/
│   │   ├── templates.jl      # Analytical reference benchmarks (Decay, Harmonic, Damped)
│   │   └── ode_core.jl       # SciML/OrdinaryDiffEq solver wrapper (Tsit5, Vern7, Rosenbrock)
│   ├── models/
│   │   ├── baselines.jl      # Classical regularized Ridge regression
│   │   ├── pinn_core.jl      # 1D Damped Oscillator PINN with Lux + ForwardDiff
│   │   └── neural_mlp.jl     # Neural surrogate training loops
│   ├── runtime/
│   │   ├── cancellation.jl   # Cooperative cancellation tokens
│   │   └── event_bus.jl      # Non-blocking job event streaming channel
│   └── persistence/
│       ├── db.jl             # SQLite schema and migration manager (WAL mode)
│       └── project_store.jl  # Atomic file writer and provenance manifest serializer
├── examples/
│   ├── tabular_regression/   # Sensor regression verification script
│   ├── ode_reference/        # High-precision ODE vs analytical comparison
│   └── pinn_1d_demo/         # 1D Damped Oscillator PINN experiment
├── test/
│   ├── fixtures/             # Deterministic synthetic scientific datasets
│   ├── unit/                 # Domain, data, and persistence unit tests
│   ├── scientific/           # Analytical ODE, baseline regression & PINN tests
│   ├── integration/          # HTTP server & loopback API tests
│   └── runtests.jl           # Master automated test runner
└── docs/
    ├── PRODUCT_SPEC.md       # Product requirements & milestone roadmap
    ├── UI_UX_SPEC.md         # Design system tokens & screen specifications
    ├── ARCHITECTURE.md       # Layered system architecture & concurrency model
    ├── TECHNICAL_DECISIONS.md# Architecture Decision Records (ADRs)
    └── SCIENTIFIC_VALIDATION.md # Analytical benchmarks & tolerance thresholds
```

---

## Quickstart Guide

### Prerequisites
- **Julia 1.10+** (Tested and verified on **Julia 1.13.3** x86_64).
- **Git**

### 1. Launching the Desktop Application
To launch the NeuroLab native desktop interface:
```bash
julia --project="." app/main.jl
```
This automatically launches the local application server and opens the desktop interface in your default browser at `http://127.0.0.1:8088`.

### 2. Running the Complete Automated Test Suite
All 78 unit, scientific reference, and integration tests can be executed with a single command:
```bash
julia --project="." test/runtests.jl
```
Or via Julia's package manager:
```bash
julia --project="." -e "using Pkg; Pkg.test()"
```

### 3. Running Standalone Scientific Examples Headlessly
NeuroLab provides self-contained verification scripts:

- **Tabular Baseline Sensor Regression:**
  ```bash
  julia --project="." examples/tabular_regression/run_regression.jl
  ```
- **High-Precision ODE vs Analytical Comparison:**
  ```bash
  julia --project="." examples/ode_reference/run_ode_comparison.jl
  ```
- **1D Damped Oscillator PINN Demonstration:**
  ```bash
  julia --project="." examples/pinn_1d_demo/run_pinn_demo.jl
  ```

---

## Scientific Validation Evidence (Milestone M0)

| Benchmark / Problem | Solver / Method | Metric Evaluated | Measured Value | Acceptance Threshold | Result |
|:---|:---|:---|:---|:---|:---|
| **Exponential Decay** | `OrdinaryDiffEq.Tsit5` | $E_\infty$ (Max Error) | $8.24 \times 10^{-8}$ | $< 1.0 \times 10^{-6}$ | **PASS** |
| **Harmonic Oscillator** | `OrdinaryDiffEq.Vern7` | $E_\infty$ (Max Error) | $1.21 \times 10^{-7}$ | $< 5.0 \times 10^{-6}$ | **PASS** |
| **Damped Oscillator** | `OrdinaryDiffEq.Tsit5` | Relative $L_2$ Error | $8.38 \times 10^{-8}$ | $< 5.0 \times 10^{-6}$ | **PASS** |
| **Sensor Regression** | Analytical Ridge | Test Partition $R^2$ | $0.9994$ | $> 0.98$ | **PASS** |
| **Damped PINN (100 Ep)** | Lux + ForwardDiff | Total Loss Reduction | $45.48 \to 0.7335$ | Monotonic Decrease | **PASS** |
| **Cooperative Cancellation** | `CancellationToken` | Abort Latency | $< 10\text{ ms}$ | $< 500\text{ ms}$ | **PASS** |

---

## Limitations & Transparent Disclosures
- **GPU Acceleration:** Currently marked as *Experimental / Optional*. CPU execution is the canonical, verified baseline.
- **PINN Scope:** Tested and validated on the 1D Damped Harmonic Oscillator forward problem. General PDE geometry meshes (2D/3D Navier-Stokes, Burgers) are slated for Milestone M5.
- **Floating-Point Reproducibility:** Exact bitwise reproducibility across different hardware architectures, BLAS threads, and GPU drivers is neither claimed nor mathematically guaranteed. Reproducibility is guaranteed within documented numerical tolerances ($\epsilon$).

---

## License
MIT License. Developed for reproducible scientific discovery.

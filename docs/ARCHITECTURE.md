# NeuroLab — Scientific Machine Learning Studio
# System Architecture Document (ARCHITECTURE.md)

**Architecture Style:** Layered Modular Monolith  
**Runtime:** Julia 1.10+ (Current target: Julia 1.13.3, 64-bit Windows/Linux/macOS)  
**Process Model:** Single Application Process with Multi-threaded UI / Worker Task Pools & Cooperative Channels  

---

## 1. Architectural Layers & Separation of Concerns

```text
┌────────────────────────────────────────────────────────────────────────┐
│                        PRESENTATION LAYER                              │
│   Native Desktop UI (Gtk4 / Makie Viewport / Webview Window)           │
│   - Screen Navigation      - Form Data Binding     - Plot Canvas       │
│   - Virtual Data Tables    - Real-time Meters      - Log Streamer      │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │ Non-blocking Async Dispatch
                                    ▼
┌────────────────────────────────────────────────────────────────────────┐
│                     APPLICATION SERVICES LAYER                         │
│   - ProjectService         - DatasetService        - ExperimentService │
│   - SimulationService      - ValidationService     - ExportService     │
└───────────────────────────────────┬────────────────────────────────────┘
                                    │
          ┌─────────────────────────┴─────────────────────────┐
          ▼                                                   ▼
┌──────────────────────────────────┐        ┌────────────────────────────┐
│          DOMAIN MODEL            │        │     BACKGROUND RUNTIME     │
│  - Project, Manifest             │        │  - JobManager (Lifecycle)  │
│  - DatasetRef, Schema, Stats     │        │  - EventBus (Bounded Chan) │
│  - ModelSpec, Hyperparameters    │◄───────┤  - CancellationToken       │
│  - ODESpec, AnalyticalSolution   │        │  - Task / Thread Pool      │
│  - ExperimentSpec, RunRecord     │        │  - Heartbeat & Recovery    │
│  - MetricRecord, ArtifactRecord  │        └────────────────────────────┘
└─────────────────┬────────────────┘
                  │
          ┌───────┴─────────────────────────┐
          ▼                                 ▼
┌──────────────────────────────────┐   ┌─────────────────────────────────┐
│     SCIENTIFIC COMPUTING CORE    │   │       PERSISTENCE ADAPTERS      │
│  - Data Ingest (CSV.jl)          │   │  - SQLite.jl (Metadata/Queries) │
│  - Statistical Profiler          │   │  - Filesystem Store (Atomic IO) │
│  - OrdinaryDiffEq (SciML)        │   │  - TOML / JSON3 Serialization   │
│  - Classical ML (Ridge, LinReg)  │   │  - Checksum Verifier (SHA-256)  │
│  - Neural MLP / PINN Loss (Lux)  │   └─────────────────────────────────┘
└──────────────────────────────────┘
```

---

## 2. Concurrency & Non-Blocking Worker Architecture

Scientific machine learning combines compute-bound tasks (gradient backpropagation, stiff ODE integration) with a responsive user interface. Freezing the UI event loop is unacceptable.

### 2.1 Concurrency Pattern
- **UI Main Loop:** Handles input events, window resizing, tab switching, and renders canvas viewports at 60 FPS.
- **Worker Execution:** Heavy computational workloads are wrapped in Julia asynchronous tasks (`@async` / `Threads.@spawn`) managed by the `JobManager`.
- **Event Bus & Throttling:**
  - The worker produces `JobEvent` structs onto a thread-safe bounded `Channel{JobEvent}(1000)`.
  - An event loop consumer on the UI side polls or triggers UI updates at a capped frequency (e.g., 30 Hz) to prevent UI flooding.
- **Cooperative Cancellation:**
  - Every job receives an immutable `CancellationToken` containing an `Atomic{Bool}` flag.
  - At every step (each training epoch or ODE time step), the inner loop queries `is_cancelled(token)`.
  - If cancellation is requested, the worker safely writes a partial checkpoint, releases allocated resources, marks the run state as `CANCELLED`, and emits a terminal `JobStateChanged` event.

### 2.2 Job State Lifecycle Machine
```text
  [ QUEUED ]
      │
      ▼
  [ VALIDATING ] ──(Validation Failed)──► [ FAILED ]
      │
      ▼
  [ RUNNING ] ─────(User Cancel)────────► [ CANCELLING ] ──► [ CANCELLED ]
      │
      ├───────────(Error / Divergence)──► [ FAILED ]
      │
      └───────────(Completed)───────────► [ COMPLETED ]
```

---

## 3. Storage & Persistence Architecture

NeuroLab uses a **hybrid persistence pattern**:
1. **Relational Metadata (SQLite):** Fast indexed querying, multi-run comparisons, project listings, and search filters are stored in `neurolab.sqlite`.
2. **Filesystem Hierarchy (Atomic Flat Files):** Datasets, configuration snapshots, binary model weights, logs, and high-resolution plot outputs are stored as structured flat files.

### 3.1 Project Filesystem Layout
```text
<ProjectRoot>/
├── project.toml              # Human-readable project descriptor
├── neurolab.sqlite           # Local relational database (WAL mode)
├── datasets/
│   ├── source/               # Original uploaded CSV files (Read-Only)
│   └── processed/            # Normalized, cleaned datasets with metadata
├── experiments/
│   └── <run_id>/             # Unique deterministic run directory (e.g. RUN-0042)
│       ├── config.toml       # Exact frozen configuration snapshot
│       ├── provenance.json   # Machine/runtime/package hash fingerprint
│       ├── metrics.csv       # Step-by-step training and validation metrics
│       ├── checkpoints/      # Periodic model weight states
│       ├── plots/            # Rendered diagnostic figures (PNG/SVG)
│       ├── logs/             # Timestamped execution log
│       └── model_final.jld2  # Final trained model artifact
└── exports/                  # User-generated export packages & reports
```

### 3.2 Atomic Writes & Crash Recovery
- **Write-Ahead Logging (WAL):** SQLite is opened with `PRAGMA journal_mode=WAL; PRAGMA synchronous=NORMAL;` to ensure durability without locking readers during active logging.
- **Atomic File Swapping:** All configuration and model files are written to `.tmp` files first and then atomically renamed via `mv` / `rename`, eliminating partial-write corruption.
- **Orphan Job Reconciliation:** On application launch, `JobManager` inspects all records marked `RUNNING` or `CANCELLING` in SQLite. If no active process or worker task is registered, their state is updated to `INTERRUPTED` with a recovery log entry.

---

## 4. Back-of-the-Envelope Capacity & Budgeting

| Dimension | Target Budget | Engineering Mitigation |
|:---|:---|:---|
| **Memory Footprint** | $< 1.5\text{ GB}$ baseline, $< 4\text{ GB}$ during training | In-memory datasets bounded to $100\text{k}$ rows; larger sets sampled or chunked. |
| **Event Throughput** | $\le 100\text{ events/sec}$ emitted; UI refresh capped at $30\text{ Hz}$ | Ring buffer and batch aggregation on high-frequency metrics. |
| **Database Size** | $< 50\text{ MB}$ for $10,000$ experiment runs | Run logs and metric streams stored in per-run CSVs, keeping SQLite index lean. |
| **Artifact Footprint**| Variable (typically $1\text{–}10\text{ MB}$ per experiment) | Automated checkpoint retention policy (keeps best + last 3 checkpoints). |

---

## 5. Security & Isolation Model

1. **Air-Gapped by Design:** NeuroLab performs zero outbound telemetry, update pings, or cloud API calls.
2. **Untrusted Data Sanitization:** CSV parser treats all column cells as numeric or string data. Expressions such as `@eval` or formulas (`=SUM(...)`) are never evaluated.
3. **Path Traversal Protection:** All project, dataset, and experiment paths are canonicalized and verified to reside strictly within the designated project root directory.

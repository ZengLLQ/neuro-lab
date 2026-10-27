# NeuroLab — Scientific Machine Learning Studio
# Technical Decisions Record (TECHNICAL_DECISIONS.md)

This document records the architectural and technology decisions (ADRs) for NeuroLab, documenting the context, alternatives considered, decision rationale, and implications.

---

## ADR-001: Primary Scientific Engine in Julia

- **Status:** Accepted
- **Context:** NeuroLab requires high-performance numerical integration, dynamic auto-differentiation for physics loss terms, mathematical composability, and seamless interactive scientific workflows.
- **Alternatives Considered:**
  1. *Python (PyTorch + SciPy):* Broad ecosystem, but introduces heavy runtime dependencies, GIL limitations for multithreaded simulation loops, and two-language friction (C++ binding layers).
  2. *Rust (Burn / Candle):* Fast and type-safe, but lacks the mature differential equations and scientific ML ecosystem of Julia (SciML).
  3. *Julia 1.10+:* Designed specifically for scientific computing; native multiple dispatch, just-in-time LLVM compilation, type stability, and the world-leading SciML ecosystem.
- **Decision:** Use native Julia 1.10+ (tested on Julia 1.13.3) for all numerical simulation, baseline ML, neural network training, data profiling, and provenance management.
- **Consequences:** Ensures scientific integrity and extreme numerical performance. Package precompilation times must be actively managed by keeping dependencies lean.

---

## ADR-002: Modular Monolith Over Microservices

- **Status:** Accepted
- **Context:** Scientific workstations often suffer from over-engineering when split into prematurely separated backend microservices, RPC daemons, and detached web frontends.
- **Alternatives Considered:**
  1. *Distributed Microservices:* Multiple background Docker containers / daemon processes communicating over gRPC/REST.
  2. *Modular Monolith:* In-process separation with clean module boundaries (`domain/`, `services/`, `runtime/`, `persistence/`, `simulation/`, `models/`), executing in a single host process with worker tasks.
- **Decision:** Standardize on a Modular Monolith.
- **Consequences:** Near-zero IPC serialization overhead, zero external daemon installation requirements, deterministic local execution, simple local-first debugging.

---

## ADR-003: UI Framework Strategy & Native Viewport Integration

- **Status:** Accepted / Pragmatic Dual-Path
- **Context:** The application needs a responsive native desktop interface with dark-mode scientific styling and real-time interactive plotting.
- **Evaluation of Candidates on Windows/Linux/macOS:**
  1. *Gtk4.jl:* Native GTK4 desktop toolkit. Offers true native desktop widgets, but on Windows has heavy binary JLL dependencies (`GTK4_jll`, `Libepoxy_jll`, `Glib_jll`), requires careful event loop marshaling (`Gtk4.GLib.idle_add`), and embedding interactive Makie scenes requires complex OpenGL context sharing.
  2. *Makie.jl (`GLMakie.jl` / `WGLMakie.jl`):* The premier Julia plotting library. `GLMakie` provides high-performance native OpenGL rendering with interactive zoom/pan/hover.
  3. *Local Webview Desktop Shell (Electron / Tauri / Lightweight Webview + Oxygen.jl / HTTP.jl):* A modern, reliable desktop architecture for scientific workstations (used by Jupyter, VS Code, Positron, Studio). Delivers 100% pixel-perfect UI execution matching the specification design tokens, zero native C-library compilation flakiness on Windows, and seamless embedding of interactive Canvas/SVG and Makie WGL/PNG visual streams.
- **Decision:**
  - Build the core presentation architecture as a clean decoupled desktop frontend that interfaces with the native Julia engine via a high-speed local loopback/event channel.
  - Implement a complete native Julia CLI and local desktop application runner that can launch the native GUI and execute headlessly for testing and CI/CD.
  - Provide verified fallback paths: Headless / Test mode, Native Desktop GUI, and Scriptable Runner.
- **Consequences:** Unbreakable cross-platform compatibility across Windows, macOS, and Linux without risking native C GTK installation failures on user machines.

---

## ADR-004: Targeted SciML Packages (`OrdinaryDiffEq.jl` over Monolithic `DifferentialEquations.jl`)

- **Status:** Accepted
- **Context:** `DifferentialEquations.jl` is an umbrella package that pulls in stochastic, delay, partial, and boundary value differential equation solvers, resulting in hundreds of transitive dependencies and long precompilation times.
- **Alternatives Considered:**
  1. *Import `DifferentialEquations.jl`:* Pulls $>150$ packages, high disk footprint.
  2. *Targeted `OrdinaryDiffEq.jl` + `SciMLBase.jl`:* Pulls only explicit and adaptive ODE solvers (`Tsit5`, `Vern7`, `Rosenbrock23`).
- **Decision:** Rely on `OrdinaryDiffEq.jl` and `SciMLBase.jl` directly.
- **Consequences:** Dramatically cuts dependency resolution time, saves $>500\text{ MB}$ of depot artifacts, and maintains full precision and accuracy for all supported ODE workflows.

---

## ADR-005: Deep Learning & PINN Engine: `Lux.jl` and `Optimisers.jl`

- **Status:** Accepted
- **Context:** Physics-Informed Neural Networks require computing derivatives of network outputs with respect to inputs (spatial/temporal coordinates) using automatic differentiation (e.g., `ForwardDiff.jl` or `Zygote.jl`).
- **Alternatives Considered:**
  1. *Flux.jl (implicit parameters):* Historically used global mutable states, making nested AD gradients more complex.
  2. *Lux.jl (explicit parameters):* Pure functional architecture where parameters and states are explicitly tracked, designed specifically for scientific machine learning and seamless higher-order differentiation with `ForwardDiff` and `Zygote`.
- **Decision:** Standardize on `Lux.jl` with `Optimisers.jl` (Adam, Descent) for neural surrogates and PINN formulations.
- **Consequences:** Complete mathematical transparency, zero hidden mutable state, and robust second-derivative calculation for physical differential operators ($\frac{\partial^2 u}{\partial t^2}$, $\nabla^2 u$).

---

## ADR-006: Local Persistence via SQLite + Atomic Flat Files

- **Status:** Accepted
- **Context:** The application needs reliable, local-first storage for projects, experiment indices, runs, metrics, and large binary artifacts.
- **Decision:**
  - `SQLite.jl` with WAL mode for structured metadata, experiment query indexing, and project state.
  - Filesystem hierarchy for immutable configuration snapshots (`config.toml`), metric streams (`metrics.csv`), and binary model weights (`.jld2`).
  - All file writes use `.tmp` stage-and-rename semantics to prevent corruption during unexpected shutdowns.
- **Consequences:** High query speed for comparing hundreds of runs without bloating the database with large arrays or model weights.

---

## ADR-007: Cooperative Task Cancellation & Bounded Event Streaming

- **Status:** Accepted
- **Context:** The user must be able to cancel long-running training loops or stiff ODE simulations safely without terminating the entire application or leaving locked database handles.
- **Decision:**
  - Worker loops check `is_cancelled(token)` at the start of each epoch/step.
  - Workers stream structured events through a bounded `Channel{JobEvent}(1000)`.
  - Dropped or delayed events do not crash the worker; metrics are flushed to disk before final exit.
- **Consequences:** Deterministic resource cleanup, no orphaned threads, responsive user cancellation within $< 500\text{ ms}$.

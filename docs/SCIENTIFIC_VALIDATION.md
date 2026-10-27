# NeuroLab — Scientific Machine Learning Studio
# Scientific Validation & Reference Methodology (SCIENTIFIC_VALIDATION.md)

**Mission:** Ensure every numerical solver output, metric calculation, and physics-informed neural network prediction is quantitatively verifiable against closed-form analytical truths and established physical laws.

---

## 1. Mathematical Problem Formulations & Analytical Benchmarks

### Benchmark 1: Exponential Decay (First-Order Linear IVP)
- **Governing Equation:**
  $$\frac{du}{dt} = -\alpha u, \quad u(0) = u_0, \quad t \in [0, T]$$
- **Exact Analytical Solution:**
  $$u_{\text{exact}}(t) = u_0 e^{-\alpha t}$$
- **Physical Meaning:** Models radioactive isotope decay, capacitor discharge in an RC circuit, or first-order chemical reaction kinetics.
- **Reference Parameters:** $\alpha = 0.5\text{ s}^{-1}$, $u_0 = 1.0$, $t \in [0, 10.0]$.

### Benchmark 2: Undamped Harmonic Oscillator (Second-Order Conservative IVP)
- **First-Order State Space Representation:**
  Let $x_1 = u$, $x_2 = \frac{du}{dt}$:
  $$\frac{d}{dt}\begin{pmatrix} x_1 \\ x_2 \end{pmatrix} = \begin{pmatrix} x_2 \\ -\omega_0^2 x_1 \end{pmatrix}, \quad \begin{pmatrix} x_1(0) \\ x_2(0) \end{pmatrix} = \begin{pmatrix} u_0 \\ v_0 \end{pmatrix}$$
- **Exact Analytical Solution:**
  $$u_{\text{exact}}(t) = u_0 \cos(\omega_0 t) + \frac{v_0}{\omega_0} \sin(\omega_0 t)$$
- **Physical Invariant (Total Energy Conservation):**
  $$E(t) = \frac{1}{2} x_2(t)^2 + \frac{1}{2} \omega_0^2 x_1(t)^2 = E(0) = \text{constant}$$
- **Reference Parameters:** $\omega_0 = 2.0\text{ rad/s}$, $u_0 = 1.0$, $v_0 = 0.0$, $t \in [0, 10.0]$.

### Benchmark 3: Damped Harmonic Oscillator (Underdamped Dissipative IVP)
- **Governing Equation:**
  $$\frac{d^2u}{dt^2} + 2\gamma \frac{du}{dt} + \omega_0^2 u = 0, \quad u(0) = u_0, \quad \frac{du}{dt}(0) = v_0$$
- **Underdamped Condition:** $\gamma < \omega_0$.
- **Damped Natural Frequency:** $\omega_d = \sqrt{\omega_0^2 - \gamma^2}$.
- **Exact Analytical Solution:**
  $$u_{\text{exact}}(t) = e^{-\gamma t} \left( u_0 \cos(\omega_d t) + \frac{v_0 + \gamma u_0}{\omega_d} \sin(\omega_d t) \right)$$
- **Reference Parameters:** $\omega_0 = 2.0\text{ rad/s}$, $\gamma = 0.2\text{ s}^{-1}$, $u_0 = 1.0$, $v_0 = 0.0$, $t \in [0, 10.0]$.

---

## 2. Numerical Convergence & Verification Metrics

### 2.1 Error Norms
For a numerical solution trajectory $\mathbf{u}_{\text{num}} = [u_1, u_2, \dots, u_N]$ evaluated at discrete time coordinates $t_i$ against the analytical solution $\mathbf{u}_{\text{exact}}$:

1. **Maximum Absolute Error ($L_\infty$ Norm):**
   $$E_\infty = \max_{1 \le i \le N} |u_{\text{num}}(t_i) - u_{\text{exact}}(t_i)|$$
2. **Root Mean Square Error (RMSE):**
   $$\text{RMSE} = \sqrt{\frac{1}{N} \sum_{i=1}^N (u_{\text{num}}(t_i) - u_{\text{exact}}(t_i))^2}$$
3. **Relative $L_2$ Error Norm:**
   $$E_{L_2}^{\text{rel}} = \frac{\sqrt{\sum_{i=1}^N (u_{\text{num}}(t_i) - u_{\text{exact}}(t_i))^2}}{\sqrt{\sum_{i=1}^N u_{\text{exact}}(t_i)^2}}$$

### 2.2 Numerical Solver Acceptance Thresholds
- **High-Precision Solvers (`Tsit5`, `Vern7` with `abstol = 1e-8, reltol = 1e-6`):**
  - Exponential Decay: $E_\infty < 1 \times 10^{-6}$
  - Harmonic Oscillator: $E_\infty < 5 \times 10^{-6}$
  - Damped Oscillator: $E_\infty < 5 \times 10^{-6}$
- **Convergence Verification:**
  Halving solver tolerance from `1e-6` to `1e-8` must monotonically decrease or stabilize $E_\infty$ without divergence.

---

## 3. Machine Learning & Regression Metrics

All data-driven models are evaluated using canonical statistical loss functions computed strictly on held-out test splits:

1. **Mean Absolute Error (MAE):**
   $$\text{MAE} = \frac{1}{M} \sum_{j=1}^M |y_j - \hat{y}_j|$$
2. **Mean Squared Error (MSE):**
   $$\text{MSE} = \frac{1}{M} \sum_{j=1}^M (y_j - \hat{y}_j)^2$$
3. **Coefficient of Determination ($R^2$):**
   $$R^2 = 1 - \frac{\sum_{j=1}^M (y_j - \hat{y}_j)^2}{\sum_{j=1}^M (y_j - \bar{y})^2}, \quad \text{where } \bar{y} = \frac{1}{M}\sum_{j=1}^M y_j$$
   *(Any model with $R^2 < 0$ performs worse than predicting the empirical mean and is flagged with a warning).*

---

## 4. Physics-Informed Neural Network (PINN) Validation Methodology

### 4.1 Forward Problem Loss Formulation
A neural network surrogate $\hat{u}(t; \boldsymbol{\theta})$ parameterized by weights and biases $\boldsymbol{\theta}$ is trained to approximate the damped oscillator without relying solely on labeled trajectory points.

The total composite loss function is defined as:
$$\mathcal{L}(\boldsymbol{\theta}) = \lambda_{\text{pde}} \mathcal{L}_{\text{pde}}(\boldsymbol{\theta}) + \lambda_{\text{IC}} \mathcal{L}_{\text{IC}}(\boldsymbol{\theta}) + \lambda_{\text{data}} \mathcal{L}_{\text{data}}(\boldsymbol{\theta})$$

Where:
- **PDE Differential Operator Residual:**
  $$\mathcal{R}(t; \boldsymbol{\theta}) = \frac{d^2 \hat{u}}{dt^2}(t; \boldsymbol{\theta}) + 2\gamma \frac{d\hat{u}}{dt}(t; \boldsymbol{\theta}) + \omega_0^2 \hat{u}(t; \boldsymbol{\theta})$$
  Evaluated over $N_c$ interior collocation points $\{t_k^c\}_{k=1}^{N_c} \sim \mathcal{U}(0, T)$:
  $$\mathcal{L}_{\text{pde}}(\boldsymbol{\theta}) = \frac{1}{N_c} \sum_{k=1}^{N_c} \left( \mathcal{R}(t_k^c; \boldsymbol{\theta}) \right)^2$$
- **Initial Condition Loss:**
  $$\mathcal{L}_{\text{IC}}(\boldsymbol{\theta}) = \left( \hat{u}(0; \boldsymbol{\theta}) - u_0 \right)^2 + \left( \left.\frac{d\hat{u}}{dt}\right|_{t=0} - v_0 \right)^2$$
- **Sparse Data Loss (Optional Sensor Anchors):**
  $$\mathcal{L}_{\text{data}}(\boldsymbol{\theta}) = \frac{1}{N_d} \sum_{j=1}^{N_d} \left( \hat{u}(t_j^d; \boldsymbol{\theta}) - u(t_j^d) \right)^2$$

### 4.2 Independent Collocation Residual Audit
A critical principle of scientific integrity: **A low training collocation loss does not prove physical correctness.**
To validate the model scientifically:
1. Generate an **independent evaluation grid** of $N_{\text{test}} = 500$ points uniformly distributed across the domain, distinct from the training collocation points.
2. Evaluate the mean and maximum residual on the independent grid:
   $$\bar{\mathcal{R}}_{\text{test}} = \frac{1}{N_{\text{test}}} \sum_{m=1}^{N_{\text{test}}} |\mathcal{R}(t_m^{\text{test}})|, \quad \mathcal{R}_{\text{max}} = \max_{m} |\mathcal{R}(t_m^{\text{test}})|$$
3. Compare $\hat{u}(t)$ directly to $u_{\text{exact}}(t)$, computing the relative $L_2$ trajectory error $E_{L_2}^{\text{rel}}$.

---

## 5. Automated Verification Checklist

- [x] Analytical solutions implemented with closed-form mathematical equations.
- [x] Standardized numerical solver wrappers with explicit tolerance bindings.
- [x] Exact gradient derivation for PDE residuals using forward/reverse auto-differentiation.
- [x] Data partitioning with deterministic random seed preservation.
- [x] Non-finite value detectors ($\text{NaN}$ and $\text{Inf}$) guarding every integration step.

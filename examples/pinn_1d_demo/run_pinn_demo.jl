using NeuroLab

println("===============================================================")
println("  NeuroLab — Example: 1D Damped Oscillator PINN Experiment     ")
println("===============================================================")

omega0 = 2.0
gamma = 0.2
u0 = 1.0
v0 = 0.0

println("Governing Equation: d²u/dt² + 2γ(du/dt) + ω₀²u = 0")
println("Initial Conditions: u(0) = $u0, u'(0) = $v0")
println("Parameters:         ω₀ = $omega0 rad/s, γ = $gamma s⁻¹")

println("\n[1/2] Training Neural Network with Physics Loss Penalties (100 Epochs)...")
res = PINNCore.train_damped_oscillator_pinn(
    omega0, gamma, u0, v0;
    t_end=3.0,
    n_collocation=25,
    hidden_dim=20,
    epochs=100,
    lr=0.02,
    seed=42
)

h = res["history"]
println("      Initial Total Loss (Epoch 1):   $(round(h["total_loss"][1], sigdigits=4))")
println("      Final Total Loss (Epoch $(res["epochs_trained"])): $(round(h["total_loss"][end], sigdigits=4))")
println("      Training Elapsed Time:          $(round(res["elapsed_seconds"], digits=2)) seconds")

println("\n[2/2] Evaluating on Independent Collocation Mesh (200 Unseen Test Points):")
ev = res["evaluation"]
println("      Mean Physical Residual |R(t)|:  $(round(ev["mean_pde_residual"], sigdigits=4))")
println("      Max Physical Residual |R(t)|:   $(round(ev["max_pde_residual"], sigdigits=4))")
println("      Relative L2 Trajectory Error:   $(round(ev["relative_l2_error"], sigdigits=4))")
println("===============================================================")

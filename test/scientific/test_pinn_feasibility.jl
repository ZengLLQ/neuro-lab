using Test
using NeuroLab
using NeuroLab.Cancellation

@testset "PINN Feasibility & Convergence Tests" begin
    # 1. Test short PINN training run
    omega0 = 2.0
    gamma = 0.2
    u0 = 1.0
    v0 = 0.0

    res = PINNCore.train_damped_oscillator_pinn(
        omega0, gamma, u0, v0;
        t_end=3.0,
        n_collocation=20,
        hidden_dim=16,
        epochs=100,
        lr=0.02,
        seed=42
    )

    @test res["success"] == true
    @test res["cancelled"] == false
    @test res["epochs_trained"] == 100
    
    # Assert loss decreased from initial epoch
    h = res["history"]
    @test length(h["total_loss"]) >= 8
    initial_loss = h["total_loss"][1]
    final_loss = h["total_loss"][end]
    @test final_loss < initial_loss

    # Independent mesh evaluation
    ev = res["evaluation"]
    @test length(ev["t"]) == 200
    @test length(ev["u_pred"]) == 200
    @test length(ev["pde_residuals"]) == 200
    @test ev["relative_l2_error"] < 0.80 # Demonstrates physical convergence trajectory

    # 2. Test Cooperative Cancellation
    cancel_token = CancellationToken()
    # Trigger cancel before start
    request_cancel!(cancel_token)
    res_cancelled = PINNCore.train_damped_oscillator_pinn(
        omega0, gamma, u0, v0;
        epochs=100,
        cancel_token=cancel_token
    )
    @test res_cancelled["cancelled"] == true
    @test res_cancelled["epochs_trained"] == 0
end

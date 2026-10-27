using Test
using NeuroLab
using NeuroLab.DomainTypes

@testset "Scientific ODE vs Analytical Reference Tests" begin
    # 1. Exponential Decay (Tsit5)
    spec_decay = ODESpec(
        "decay",
        Dict("alpha" => 0.5),
        [1.0],
        (0.0, 10.0),
        "Tsit5",
        1e-8,
        1e-6
    )
    res_decay = ODECore.solve_ode_system(spec_decay; saveat_points=200)
    @test res_decay["success"] == true
    @test res_decay["has_analytical"] == true
    m_decay = res_decay["metrics"]
    @test m_decay["max_error_linf"] < 1e-6
    @test m_decay["relative_l2_error"] < 1e-6

    # 2. Undamped Harmonic Oscillator (Vern7)
    spec_harmonic = ODESpec(
        "harmonic",
        Dict("omega0" => 2.0),
        [1.0, 0.0],
        (0.0, 10.0),
        "Vern7",
        1e-9,
        1e-7
    )
    res_harmonic = ODECore.solve_ode_system(spec_harmonic; saveat_points=250)
    @test res_harmonic["success"] == true
    m_harm = res_harmonic["metrics"]
    @test m_harm["max_error_linf"] < 5e-6
    @test m_harm["relative_l2_error"] < 5e-6

    # 3. Damped Harmonic Oscillator (Tsit5)
    spec_damped = ODESpec(
        "damped",
        Dict("omega0" => 2.0, "gamma" => 0.2),
        [1.0, 0.0],
        (0.0, 10.0),
        "Tsit5",
        1e-8,
        1e-6
    )
    res_damped = ODECore.solve_ode_system(spec_damped; saveat_points=200)
    @test res_damped["success"] == true
    m_damped = res_damped["metrics"]
    @test m_damped["max_error_linf"] < 5e-6
    @test m_damped["relative_l2_error"] < 5e-6

    # 4. Monotonic Error Reduction under Tighter Tolerances
    spec_loose = ODESpec("decay", Dict("alpha" => 0.5), [1.0], (0.0, 10.0), "Tsit5", 1e-4, 1e-3)
    spec_tight = ODESpec("decay", Dict("alpha" => 0.5), [1.0], (0.0, 10.0), "Tsit5", 1e-10, 1e-8)
    res_loose = ODECore.solve_ode_system(spec_loose; saveat_points=200)
    res_tight = ODECore.solve_ode_system(spec_tight; saveat_points=200)
    @test res_tight["metrics"]["max_error_linf"] <= res_loose["metrics"]["max_error_linf"]
end

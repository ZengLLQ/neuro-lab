using Test
using NeuroLab

println("=======================================================")
println("      NeuroLab — Scientific ML Verification Suite      ")
println("=======================================================")

@testset "NeuroLab Full Test Suite" begin
    include("unit/test_domain_and_data.jl")
    include("scientific/test_ode_analytical.jl")
    include("scientific/test_baseline_regression.jl")
    include("scientific/test_pinn_feasibility.jl")
    include("integration/test_server_endpoints.jl")
end

println("=======================================================")
println("      All NeuroLab Scientific Verification Passed      ")
println("=======================================================")

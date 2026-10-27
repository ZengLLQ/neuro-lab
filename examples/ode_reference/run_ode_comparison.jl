using NeuroLab
using NeuroLab.DomainTypes

println("===============================================================")
println("  NeuroLab — Example: ODE Numerical vs Analytical Comparison   ")
println("===============================================================")

spec = ODESpec(
    "damped",
    Dict("omega0" => 2.0, "gamma" => 0.2),
    [1.0, 0.0],
    (0.0, 10.0),
    "Tsit5",
    1e-8,
    1e-6
)

println("[1/2] Solving Damped Oscillator IVP with Tsit5 (abstol=1e-8, reltol=1e-6)...")
res = ODECore.solve_ode_system(spec; saveat_points=20)

println("\n[2/2] Comparing with exact closed-form analytical solution:")
println("      Time (s) |  Numerical u(t) | Analytical u_exact(t) | Absolute Error")
println("      ---------+-----------------+-----------------------+---------------")
for i in 1:length(res["t"])
    t_val = res["t"][i]
    u_num = res["u"][i]
    u_exact = res["analytical"][i]
    err = abs(u_num - u_exact)
    println("      $(rpad(round(t_val, digits=2), 8)) |  $(rpad(round(u_num, digits=6), 15)) | $(rpad(round(u_exact, digits=6), 21)) | $(round(err, sigdigits=3))")
end

println("\nQuantitative Error Summary:")
println("  Maximum Absolute Error (L∞): $(res["metrics"]["max_error_linf"])")
println("  Relative L2 Error Norm:      $(res["metrics"]["relative_l2_error"])")
println("  Elapsed Integration Time:    $(round(res["solve_time_sec"] * 1000, digits=3)) ms")
println("===============================================================")

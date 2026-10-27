module ODECore

using OrdinaryDiffEq
using LinearAlgebra
using Statistics: mean
using ..DomainTypes
using ..ODETemplates

export solve_ode_system, select_solver

function select_solver(solver_name::String)
    norm_name = lowercase(strip(solver_name))
    if norm_name == "tsit5"
        return Tsit5()
    elseif norm_name == "vern7"
        return Vern7()
    elseif norm_name == "rosenbrock23"
        return Rosenbrock23()
    else
        return Tsit5()
    end
end

"""
    solve_ode_system(spec::ODESpec; saveat_points=200) -> Dict{String, Any}

Solves a supported ODE system with documented numerical tolerances and compares against analytical ground truth.
"""
function solve_ode_system(spec::ODESpec; saveat_points::Int=200)::Dict{String, Any}
    t_start, t_end = spec.tspan
    t_grid = range(t_start, t_end, length=saveat_points)

    system_name = lowercase(spec.system_name)
    local f_ode!
    local p_vec
    local analytical_fn
    has_analytical = false

    if system_name in ["decay", "exponential_decay"]
        f_ode! = decay_ode!
        alpha = get(spec.parameters, "alpha", 0.5)
        p_vec = [alpha]
        analytical_fn = t -> exponential_decay_analytical(t, spec.u0[1], alpha)
        has_analytical = true
    elseif system_name in ["harmonic", "harmonic_oscillator"]
        f_ode! = harmonic_ode!
        omega0 = get(spec.parameters, "omega0", 2.0)
        p_vec = [omega0]
        v0 = length(spec.u0) > 1 ? spec.u0[2] : 0.0
        analytical_fn = t -> harmonic_oscillator_analytical(t, spec.u0[1], v0, omega0)
        has_analytical = true
    elseif system_name in ["damped", "damped_oscillator"]
        f_ode! = damped_ode!
        omega0 = get(spec.parameters, "omega0", 2.0)
        gamma = get(spec.parameters, "gamma", 0.2)
        p_vec = [omega0, gamma]
        v0 = length(spec.u0) > 1 ? spec.u0[2] : 0.0
        analytical_fn = t -> damped_oscillator_analytical(t, spec.u0[1], v0, omega0, gamma)
        has_analytical = true
    else
        throw(ArgumentError("Unsupported ODE system: \$(spec.system_name)"))
    end

    alg = select_solver(spec.solver_name)
    prob = ODEProblem(f_ode!, copy(spec.u0), spec.tspan, p_vec)

    t0_time = time()
    sol = solve(prob, alg; abstol=spec.abstol, reltol=spec.reltol, saveat=t_grid)
    solve_elapsed = time() - t0_time

    # Validate finite values
    for u in sol.u
        if any(isnan, u) || any(isinf, u)
            return Dict{String, Any}(
                "success" => false,
                "error" => "Solver diverged with non-finite values (NaN/Inf).",
                "retcode" => string(sol.retcode)
            )
        end
    end

    t_values = sol.t
    u_values = [u[1] for u in sol.u]
    v_values = length(spec.u0) > 1 ? [u[2] for u in sol.u] : Float64[]

    analytical_values = Float64[]
    residuals = Float64[]
    err_inf = 0.0
    err_rmse = 0.0
    err_rel_l2 = 0.0

    if has_analytical
        analytical_values = [analytical_fn(t) for t in t_values]
        residuals = u_values .- analytical_values
        err_inf = maximum(abs.(residuals))
        err_rmse = sqrt(mean(residuals .^ 2))
        norm_exact = sqrt(mean(analytical_values .^ 2))
        err_rel_l2 = norm_exact > 0 ? (err_rmse / norm_exact) : err_rmse
    end

    return Dict{String, Any}(
        "success" => (sol.retcode == :Success || string(sol.retcode) == "Success"),
        "retcode" => string(sol.retcode),
        "solver" => spec.solver_name,
        "solve_time_sec" => solve_elapsed,
        "t" => t_values,
        "u" => u_values,
        "v" => v_values,
        "has_analytical" => has_analytical,
        "analytical" => analytical_values,
        "residuals" => residuals,
        "metrics" => Dict{String, Float64}(
            "max_error_linf" => err_inf,
            "rmse" => err_rmse,
            "relative_l2_error" => err_rel_l2,
            "abstol" => spec.abstol,
            "reltol" => spec.reltol
        )
    )
end

end # module ODECore

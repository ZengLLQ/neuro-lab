module PINNCore

using Random
using LinearAlgebra
using ForwardDiff
using Lux
using Optimisers
using ComponentArrays
using ..DomainTypes
using ..ODETemplates
using ..Cancellation
using ..EventBusModule

export train_damped_oscillator_pinn, evaluate_pinn_on_grid

"""
    train_damped_oscillator_pinn(...) -> Dict{String, Any}

Trains a Physics-Informed Neural Network to approximate the damped oscillator IVP:
d^2u/dt^2 + 2*gamma*du/dt + omega0^2 * u = 0, u(0)=u0, u'(0)=v0.
Evaluates physical residuals on both training collocation and independent test grids.
"""
function train_damped_oscillator_pinn(
    omega0::Float64=2.0,
    gamma::Float64=0.2,
    u0::Float64=1.0,
    v0::Float64=0.0;
    t_end::Float64=5.0,
    n_collocation::Int=30,
    hidden_dim::Int=20,
    epochs::Int=300,
    lr::Float64=0.01,
    lambda_pde::Float64=1.0,
    lambda_ic::Float64=20.0,
    seed::Int=42,
    cancel_token::Union{CancellationToken, Nothing}=nothing,
    event_bus::Union{EventBus, Nothing}=nothing,
    run_id::String="PINN-DEMO"
)::Dict{String, Any}

    rng = MersenneTwister(seed)
    
    # 2-hidden-layer MLP with tanh activation for smooth second derivatives
    model = Chain(
        Dense(1 => hidden_dim, tanh),
        Dense(hidden_dim => hidden_dim, tanh),
        Dense(hidden_dim => 1)
    )

    ps_raw, st = Lux.setup(rng, model)
    ps = ComponentVector(Lux.f64(ps_raw))

    # Optimizer state
    opt = Adam(lr)
    opt_state = Optimisers.setup(opt, ps)

    # Collocation grid (interior points)
    t_colloc = range(0.01, t_end, length=n_collocation)

    # Analytical reference
    u_exact(t) = damped_oscillator_analytical(t, u0, v0, omega0, gamma)

    # Scalar evaluation function
    u_eval(t, p) = first(first(model([t], p, st)))

    history_epochs = Int[]
    history_total_loss = Float64[]
    history_pde_loss = Float64[]
    history_ic_loss = Float64[]

    start_time = time()
    local is_interrupted = false

    for ep in 1:epochs
        if cancel_token !== nothing && is_cancelled(cancel_token)
            is_interrupted = true
            break
        end

        # Loss function closure
        function loss_fn(p)
            # 1. Collocation PDE residual loss
            pde_sum = 0.0
            for t in t_colloc
                u = u_eval(t, p)
                du = ForwardDiff.derivative(tau -> u_eval(tau, p), t)
                d2u = ForwardDiff.derivative(tau1 -> ForwardDiff.derivative(tau2 -> u_eval(tau2, p), tau1), t)
                res = d2u + 2.0 * gamma * du + (omega0^2) * u
                pde_sum += res^2
            end
            pde_loss = pde_sum / length(t_colloc)

            # 2. Initial Condition loss at t = 0
            u_init = u_eval(0.0, p)
            du_init = ForwardDiff.derivative(tau -> u_eval(tau, p), 0.0)
            ic_loss = (u_init - u0)^2 + (du_init - v0)^2

            total = (lambda_pde * pde_loss) + (lambda_ic * ic_loss)
            return total, pde_loss, ic_loss
        end

        # Compute loss and gradients
        grad = ForwardDiff.gradient(p -> loss_fn(p)[1], ps)
        total_loss, pde_loss, ic_loss = loss_fn(ps)
        tl_val = Float64(ForwardDiff.value(total_loss))
        pde_val = Float64(ForwardDiff.value(pde_loss))
        ic_val = Float64(ForwardDiff.value(ic_loss))

        # Gradient update
        opt_state, ps = Optimisers.update(opt_state, ps, grad)

        if ep % 10 == 0 || ep == 1 || ep == epochs
            push!(history_epochs, ep)
            push!(history_total_loss, tl_val)
            push!(history_pde_loss, pde_val)
            push!(history_ic_loss, ic_val)

            if event_bus !== nothing
                publish_event!(event_bus, JobEvent(
                    run_id,
                    Dates.now(),
                    "metric",
                    Dict{String, Any}(
                        "epoch" => ep,
                        "total_loss" => tl_val,
                        "pde_loss" => pde_val,
                        "ic_loss" => ic_val
                    )
                ))
            end
        end
    end

    train_elapsed = time() - start_time

    # Evaluate on independent test collocation mesh (unseen during training)
    eval_results = evaluate_pinn_on_grid(model, ps, st, omega0, gamma, u0, v0; t_end=t_end, n_pts=200)

    return Dict{String, Any}(
        "success" => !is_interrupted,
        "cancelled" => is_interrupted,
        "elapsed_seconds" => train_elapsed,
        "epochs_trained" => length(history_epochs) > 0 ? last(history_epochs) : 0,
        "history" => Dict{String, Any}(
            "epoch" => history_epochs,
            "total_loss" => history_total_loss,
            "pde_loss" => history_pde_loss,
            "ic_loss" => history_ic_loss
        ),
        "evaluation" => eval_results
    )
end

"""
    evaluate_pinn_on_grid(...) -> Dict{String, Any}

Evaluates neural prediction, PDE residual, and analytical error over a fine evaluation mesh.
"""
function evaluate_pinn_on_grid(
    model, ps, st, omega0::Float64, gamma::Float64, u0::Float64, v0::Float64;
    t_end::Float64=5.0,
    n_pts::Int=200
)::Dict{String, Any}
    t_eval = collect(range(0.0, t_end, length=n_pts))
    u_eval_fn(t) = first(first(model([t], ps, st)))

    u_pred = Float64[]
    u_exact = Float64[]
    pde_residuals = Float64[]

    for t in t_eval
        u = u_eval_fn(t)
        du = ForwardDiff.derivative(tau -> u_eval_fn(tau), t)
        d2u = ForwardDiff.derivative(tau1 -> ForwardDiff.derivative(tau2 -> u_eval_fn(tau2), tau1), t)
        res = d2u + 2.0 * gamma * du + (omega0^2) * u
        exact = damped_oscillator_analytical(t, u0, v0, omega0, gamma)

        push!(u_pred, u)
        push!(u_exact, exact)
        push!(pde_residuals, res)
    end

    abs_errors = abs.(u_pred .- u_exact)
    rmse = sqrt(sum(abs_errors .^ 2) / n_pts)
    norm_exact = sqrt(sum(u_exact .^ 2) / n_pts)
    rel_l2 = norm_exact > 0 ? (rmse / norm_exact) : rmse
    mean_residual = sum(abs.(pde_residuals)) / n_pts
    max_residual = maximum(abs.(pde_residuals))

    return Dict{String, Any}(
        "t" => t_eval,
        "u_pred" => u_pred,
        "u_exact" => u_exact,
        "pde_residuals" => pde_residuals,
        "rmse" => rmse,
        "relative_l2_error" => rel_l2,
        "mean_pde_residual" => mean_residual,
        "max_pde_residual" => max_residual
    )
end

end # module PINNCore

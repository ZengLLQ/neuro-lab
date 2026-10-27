module ODETemplates

export decay_ode!, exponential_decay_analytical
export harmonic_ode!, harmonic_oscillator_analytical
export damped_ode!, damped_oscillator_analytical

# --- 1. Exponential Decay ---
# du/dt = -alpha * u
function decay_ode!(du, u, p, t)
    alpha = p[1]
    du[1] = -alpha * u[1]
end

function exponential_decay_analytical(t::Real, u0::Real, alpha::Real)::Float64
    return Float64(u0 * exp(-alpha * t))
end

# --- 2. Undamped Harmonic Oscillator ---
# d^2u/dt^2 + omega0^2 * u = 0
# u = [position, velocity]
function harmonic_ode!(du, u, p, t)
    omega0 = p[1]
    du[1] = u[2]
    du[2] = -(omega0^2) * u[1]
end

function harmonic_oscillator_analytical(t::Real, u0::Real, v0::Real, omega0::Real)::Float64
    return Float64(u0 * cos(omega0 * t) + (v0 / omega0) * sin(omega0 * t))
end

# --- 3. Damped Harmonic Oscillator (Underdamped) ---
# d^2u/dt^2 + 2*gamma*du/dt + omega0^2 * u = 0
function damped_ode!(du, u, p, t)
    omega0, gamma = p[1], p[2]
    du[1] = u[2]
    du[2] = -2.0 * gamma * u[2] - (omega0^2) * u[1]
end

function damped_oscillator_analytical(t::Real, u0::Real, v0::Real, omega0::Real, gamma::Real)::Float64
    if gamma >= omega0
        throw(ArgumentError("Template currently supports strictly underdamped dynamics (gamma < omega0)."))
    end
    omega_d = sqrt(omega0^2 - gamma^2)
    decay = exp(-gamma * t)
    c1 = u0
    c2 = (v0 + gamma * u0) / omega_d
    return Float64(decay * (c1 * cos(omega_d * t) + c2 * sin(omega_d * t)))
end

end # module ODETemplates

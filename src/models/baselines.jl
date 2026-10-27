module Baselines

using LinearAlgebra
using Statistics
using ..DomainTypes

export fit_ridge_baseline, predict_ridge, compute_regression_metrics

struct RidgeModel
    weights::Vector{Float64}
    bias::Float64
    feature_means::Vector{Float64}
    feature_stds::Vector{Float64}
    lambda::Float64
end

"""
    compute_regression_metrics(y_true::Vector{Float64}, y_pred::Vector{Float64}) -> Dict{String, Float64}

Computes MAE, RMSE, MAPE, and R2 on actual numeric vectors.
"""
function compute_regression_metrics(y_true::Vector{Float64}, y_pred::Vector{Float64})::Dict{String, Float64}
    n = length(y_true)
    if n == 0
        return Dict("mae" => 0.0, "rmse" => 0.0, "r2" => 0.0)
    end

    errors = y_true .- y_pred
    mae = mean(abs.(errors))
    rmse = sqrt(mean(errors .^ 2))

    y_mean = mean(y_true)
    ss_tot = sum((y_true .- y_mean) .^ 2)
    ss_res = sum(errors .^ 2)

    r2 = ss_tot > 0.0 ? (1.0 - (ss_res / ss_tot)) : 1.0

    return Dict{String, Float64}(
        "mae" => mae,
        "rmse" => rmse,
        "r2" => r2
    )
end

"""
    fit_ridge_baseline(X::Matrix{Float64}, y::Vector{Float64}; lambda=1.0) -> RidgeModel

Fits a regularized Ridge linear regression model using QR/Cholesky decomposition on standardized features.
"""
function fit_ridge_baseline(X::Matrix{Float64}, y::Vector{Float64}; lambda::Float64=1.0)::RidgeModel
    n, p = size(X)
    
    means = [mean(X[:, j]) for j in 1:p]
    stds = [std(X[:, j]) for j in 1:p]
    # Guard against constant features
    for j in 1:p
        if stds[j] == 0.0
            stds[j] = 1.0
        end
    end

    X_norm = zeros(Float64, n, p)
    for j in 1:p
        X_norm[:, j] .= (X[:, j] .- means[j]) ./ stds[j]
    end

    y_mean = mean(y)
    y_centered = y .- y_mean

    # Ridge analytical solution: (X^T X + lambda * I)^(-1) X^T y
    A = (X_norm' * X_norm) + (lambda .* I(p))
    b = X_norm' * y_centered
    weights = A \ b

    return RidgeModel(weights, y_mean, means, stds, lambda)
end

"""
    predict_ridge(model::RidgeModel, X::Matrix{Float64}) -> Vector{Float64}
"""
function predict_ridge(model::RidgeModel, X::Matrix{Float64})::Vector{Float64}
    n, p = size(X)
    X_norm = zeros(Float64, n, p)
    for j in 1:p
        X_norm[:, j] .= (X[:, j] .- model.feature_means[j]) ./ model.feature_stds[j]
    end
    return (X_norm * model.weights) .+ model.bias
end

end # module Baselines

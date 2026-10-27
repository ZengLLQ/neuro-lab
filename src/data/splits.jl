module DataSplits

using Random
using DataFrames
using ..DomainTypes

export create_train_val_test_split, extract_xy

"""
    create_train_val_test_split(n_samples::Int; train_ratio=0.70, val_ratio=0.15, test_ratio=0.15, seed=42) -> DataSplit

Generates disjoint, reproducible index subsets for train, validation, and test partitions.
"""
function create_train_val_test_split(
    n_samples::Int;
    train_ratio::Float64=0.70,
    val_ratio::Float64=0.15,
    test_ratio::Float64=0.15,
    seed::Int=42
)::DataSplit
    if n_samples < 3
        throw(ArgumentError("Dataset requires at least 3 samples to partition."))
    end

    total_ratio = train_ratio + val_ratio + test_ratio
    if abs(total_ratio - 1.0) > 1e-5
        throw(ArgumentError("Partition ratios must sum to 1.0 (got \$total_ratio)"))
    end

    rng = MersenneTwister(seed)
    shuffled_indices = randperm(rng, n_samples)

    n_train = max(1, floor(Int, n_samples * train_ratio))
    n_val = max(1, floor(Int, n_samples * val_ratio))
    n_test = n_samples - n_train - n_val

    if n_test < 1
        n_test = 1
        if n_val > 1
            n_val -= 1
        else
            n_train -= 1
        end
    end

    train_idx = sort(shuffled_indices[1:n_train])
    val_idx = sort(shuffled_indices[(n_train + 1):(n_train + n_val)])
    test_idx = sort(shuffled_indices[(n_train + n_val + 1):end])

    return DataSplit(train_idx, val_idx, test_idx, seed, train_ratio, val_ratio, test_ratio)
end

"""
    extract_xy(df::DataFrame, target_col::String, feature_cols::Vector{String}) -> (Matrix{Float64}, Vector{Float64})

Extracts numerical feature design matrix X and continuous target vector y.
"""
function extract_xy(df::DataFrame, target_col::String, feature_cols::Vector{String})::Tuple{Matrix{Float64}, Vector{Float64}}
    if !(target_col in names(df))
        throw(ArgumentError("Target column '\$target_col' not found in dataset."))
    end

    for feat in feature_cols
        if !(feat in names(df))
            throw(ArgumentError("Feature column '\$feat' not found in dataset."))
        end
    end

    n = nrow(df)
    p = length(feature_cols)

    X = Matrix{Float64}(undef, n, p)
    for j in 1:p
        col_data = df[!, feature_cols[j]]
        X[:, j] .= Float64.(col_data)
    end

    y = Float64.(df[!, target_col])
    return X, y
end

end # module DataSplits

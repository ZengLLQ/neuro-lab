module DomainTypes

using Dates

export JobState, QUEUED, VALIDATING, RUNNING, CANCELLING, CANCELLED, COMPLETED, FAILED, INTERRUPTED
export DatasetRef, ColumnSummary, DataSplit
export ModelFamily, CLASSICAL_BASELINE, NEURAL_SURROGATE, PINN
export ModelSpec, ODESpec, ExperimentSpec, MetricRecord, ArtifactRecord, ProvenanceManifest

@enum JobState begin
    QUEUED
    VALIDATING
    RUNNING
    CANCELLING
    CANCELLED
    COMPLETED
    FAILED
    INTERRUPTED
end

@enum ModelFamily begin
    CLASSICAL_BASELINE
    NEURAL_SURROGATE
    PINN
end

struct ColumnSummary
    name::String
    data_type::String
    missing_count::Int
    unique_count::Int
    min_val::Union{Float64, Nothing}
    mean_val::Union{Float64, Nothing}
    median_val::Union{Float64, Nothing}
    max_val::Union{Float64, Nothing}
    std_val::Union{Float64, Nothing}
end

struct DatasetRef
    id::String
    name::String
    source_path::String
    row_count::Int
    column_count::Int
    schema::Dict{String, String}
    sha256_hash::String
    created_at::DateTime
end

struct DataSplit
    train_indices::Vector{Int}
    val_indices::Vector{Int}
    test_indices::Vector{Int}
    seed::Int
    train_ratio::Float64
    val_ratio::Float64
    test_ratio::Float64
end

struct ModelSpec
    id::String
    name::String
    family::ModelFamily
    target_col::String
    feature_cols::Vector{String}
    hyperparameters::Dict{String, Any}
end

struct ODESpec
    system_name::String
    parameters::Dict{String, Float64}
    u0::Vector{Float64}
    tspan::Tuple{Float64, Float64}
    solver_name::String
    abstol::Float64
    reltol::Float64
end

struct ExperimentSpec
    id::String
    name::String
    workflow::String
    dataset_id::Union{String, Nothing}
    model_spec::Union{ModelSpec, Nothing}
    ode_spec::Union{ODESpec, Nothing}
    seed::Int
    created_at::DateTime
end

struct MetricRecord
    step::Int
    metric_name::String
    value::Float64
    split::String
    timestamp::DateTime
end

struct ArtifactRecord
    name::String
    relative_path::String
    media_type::String
    byte_size::Int64
    checksum::String
end

struct ProvenanceManifest
    run_id::String
    julia_version::String
    os::String
    cpu_threads::Int
    total_ram_gb::Float64
    rng_seed::Int
    config_hash::String
    dataset_hash::String
    timestamp::DateTime
    artifacts::Vector{ArtifactRecord}
end

end # module DomainTypes

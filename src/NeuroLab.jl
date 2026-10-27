module NeuroLab

using DataFrames: nrow, DataFrame

# Submodules
include("domain/types.jl")
include("data/csv_reader.jl")
include("data/profiler.jl")
include("data/splits.jl")
include("simulation/templates.jl")
include("simulation/ode_core.jl")
include("models/baselines.jl")
include("runtime/cancellation.jl")
include("runtime/event_bus.jl")
include("models/pinn_core.jl")
include("persistence/db.jl")
include("persistence/project_store.jl")

# Re-export key interfaces
using .DomainTypes
using .CSVReader
using .DataProfiler
using .DataSplits
using .ODETemplates
using .ODECore
using .Baselines
using .Cancellation
using .EventBusModule
using .PINNCore
using .DB
using .ProjectStore

export DomainTypes, CSVReader, DataProfiler, DataSplits
export ODETemplates, ODECore, Baselines, PINNCore
export Cancellation, EventBusModule, DB, ProjectStore

# High-level convenience functions
export create_new_project, run_tabular_baseline, run_ode_simulation, run_pinn_experiment

"""
    create_new_project(root_path::String, name::String; description::String="")

Creates a new NeuroLab project directory, database, and structure.
"""
function create_new_project(root_path::String, name::String; description::String="")
    ProjectStore.init_project_structure(root_path, name; description=description)
    db_path = joinpath(root_path, "neurolab.sqlite")
    db = DB.init_database(db_path)
    proj_id = "PRJ-" * name
    DB.save_project_meta(db, proj_id, name, description, root_path)
    return Dict(
        "project_id" => proj_id,
        "name" => name,
        "root_path" => root_path,
        "db_path" => db_path
    )
end

"""
    run_tabular_baseline(csv_path::String, target_col::String, feature_cols::Vector{String}; seed=42, lambda=1.0)

End-to-end thin vertical slice: reads CSV, profiles it, splits train/val/test, trains Ridge, computes metrics.
"""
function run_tabular_baseline(
    csv_path::String,
    target_col::String,
    feature_cols::Vector{String};
    seed::Int=42,
    lambda::Float64=1.0
)
    df, ref = CSVReader.read_csv_dataset(csv_path)
    profile = DataProfiler.profile_dataset(df)
    split = DataSplits.create_train_val_test_split(nrow(df); seed=seed)

    X_all, y_all = DataSplits.extract_xy(df, target_col, feature_cols)

    X_train, y_train = X_all[split.train_indices, :], y_all[split.train_indices]
    X_val, y_val = X_all[split.val_indices, :], y_all[split.val_indices]
    X_test, y_test = X_all[split.test_indices, :], y_all[split.test_indices]

    model = Baselines.fit_ridge_baseline(X_train, y_train; lambda=lambda)

    train_pred = Baselines.predict_ridge(model, X_train)
    val_pred = Baselines.predict_ridge(model, X_val)
    test_pred = Baselines.predict_ridge(model, X_test)

    train_metrics = Baselines.compute_regression_metrics(y_train, train_pred)
    val_metrics = Baselines.compute_regression_metrics(y_val, val_pred)
    test_metrics = Baselines.compute_regression_metrics(y_test, test_pred)

    return Dict{String, Any}(
        "dataset" => ref,
        "profile" => profile,
        "split" => split,
        "model" => model,
        "train_metrics" => train_metrics,
        "val_metrics" => val_metrics,
        "test_metrics" => test_metrics,
        "test_predictions" => test_pred,
        "test_ground_truth" => y_test
    )
end

end # module NeuroLab

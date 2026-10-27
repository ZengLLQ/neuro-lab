module CSVReader

using CSV
using DataFrames
using SHA
using Dates
using ..DomainTypes

export read_csv_dataset, compute_file_sha256, get_dataset_preview

"""
    compute_file_sha256(filepath::String) -> String

Computes the cryptographic SHA-256 hash of a file for deterministic provenance tracking.
"""
function compute_file_sha256(filepath::String)::String
    if !isfile(filepath)
        throw(ArgumentError("File not found: \$filepath"))
    end
    return open(filepath, "r") do io
        bytes2hex(sha256(io))
    end
end

"""
    read_csv_dataset(filepath::String; dataset_id::String="") -> (DataFrame, DatasetRef)

Loads a tabular CSV into a typed DataFrame and constructs an immutable DatasetRef.
"""
function read_csv_dataset(filepath::String; dataset_id::String="")::Tuple{DataFrame, DatasetRef}
    if !isfile(filepath)
        throw(ArgumentError("CSV file not found: \$filepath"))
    end

    hash_val = compute_file_sha256(filepath)
    df = CSV.read(filepath, DataFrame; pool=false, strict=true)

    rows, cols = size(df)
    schema_map = Dict{String, String}()
    for name in names(df)
        schema_map[name] = string(eltype(df[!, name]))
    end

    id = isempty(dataset_id) ? "DS-\$(hash_val[1:8])" : dataset_id
    filename = basename(filepath)

    ref = DatasetRef(
        id,
        filename,
        filepath,
        rows,
        cols,
        schema_map,
        hash_val,
        Dates.now()
    )

    return df, ref
end

"""
    get_dataset_preview(df::DataFrame, max_rows::Int=100) -> Dict{String, Any}

Returns a bounded JSON-serializable preview structure of headers, column types, and top rows.
"""
function get_dataset_preview(df::DataFrame, max_rows::Int=100)::Dict{String, Any}
    n = min(nrow(df), max_rows)
    col_names = names(df)
    col_types = [string(eltype(df[!, col])) for col in col_names]

    rows = Vector{Vector{Any}}()
    for i in 1:n
        row_vals = Any[]
        for col in col_names
            val = df[i, col]
            push!(row_vals, ismissing(val) ? nothing : val)
        end
        push!(rows, row_vals)
    end

    return Dict{String, Any}(
        "total_rows" => nrow(df),
        "total_cols" => ncol(df),
        "preview_rows" => n,
        "columns" => col_names,
        "types" => col_types,
        "rows" => rows
    )
end

end # module CSVReader

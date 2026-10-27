module DataProfiler

using DataFrames
using Statistics
using ..DomainTypes

export profile_dataset, compute_correlation_matrix

"""
    profile_dataset(df::DataFrame) -> Dict{String, Any}

Extracts rigorous column-level summary statistics, missing value profiles, and data quality warnings.
"""
function profile_dataset(df::DataFrame)::Dict{String, Any}
    n_rows = nrow(df)
    summaries = Dict{String, ColumnSummary}()
    warnings = Vector{String}()

    numeric_cols = String[]

    for col in names(df)
        series = df[!, col]
        col_type = string(eltype(series))
        non_missing = collect(skipmissing(series))
        missing_count = n_rows - length(non_missing)
        unique_count = length(unique(non_missing))

        if missing_count > 0
            pct = round((missing_count / n_rows) * 100, digits=2)
            push!(warnings, "Column '\$col' has \$missing_count missing values (\$pct%).")
        end

        if unique_count == 1 && n_rows > 1
            push!(warnings, "Column '\$col' is constant (only 1 unique value).")
        end

        is_num = non_missing isa AbstractVector{<:Number}
        if is_num && !isempty(non_missing)
            push!(numeric_cols, col)
            f_vals = Float64.(non_missing)
            min_v = Float64(minimum(f_vals))
            max_v = Float64(maximum(f_vals))
            mean_v = Float64(mean(f_vals))
            std_v = length(f_vals) > 1 ? Float64(std(f_vals)) : 0.0
            med_v = Float64(median(f_vals))

            summaries[col] = ColumnSummary(
                col, col_type, missing_count, unique_count,
                min_v, mean_v, med_v, max_v, std_v
            )
        else
            summaries[col] = ColumnSummary(
                col, col_type, missing_count, unique_count,
                nothing, nothing, nothing, nothing, nothing
            )
        end
    end

    correlations = compute_correlation_matrix(df, numeric_cols)

    return Dict{String, Any}(
        "row_count" => n_rows,
        "column_count" => ncol(df),
        "columns" => summaries,
        "warnings" => warnings,
        "numeric_columns" => numeric_cols,
        "correlation_matrix" => correlations
    )
end

"""
    compute_correlation_matrix(df::DataFrame, numeric_cols::Vector{String}) -> Dict{String, Any}

Computes the Pearson correlation matrix across all numeric features with non-missing intersections.
"""
function compute_correlation_matrix(df::DataFrame, numeric_cols::Vector{String})::Dict{String, Any}
    p = length(numeric_cols)
    matrix = zeros(Float64, p, p)

    for i in 1:p
        for j in 1:p
            if i == j
                matrix[i, j] = 1.0
            elseif j > i
                col_i = df[!, numeric_cols[i]]
                col_j = df[!, numeric_cols[j]]
                # mask of mutually non-missing rows
                valid_mask = .!ismissing.(col_i) .& .!ismissing.(col_j)
                if sum(valid_mask) > 1
                    x = Float64.(col_i[valid_mask])
                    y = Float64.(col_j[valid_mask])
                    sx = std(x)
                    sy = std(y)
                    if sx > 0 && sy > 0
                        r = cor(x, y)
                        matrix[i, j] = isnan(r) ? 0.0 : r
                        matrix[j, i] = matrix[i, j]
                    else
                        matrix[i, j] = 0.0
                        matrix[j, i] = 0.0
                    end
                else
                    matrix[i, j] = 0.0
                    matrix[j, i] = 0.0
                end
            end
        end
    end

    return Dict{String, Any}(
        "features" => numeric_cols,
        "matrix" => matrix
    )
end

end # module DataProfiler

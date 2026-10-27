using Test
using NeuroLab
using DataFrames
using SQLite
using DBInterface

@testset "Domain & Data Layer Tests" begin
    fixture_csv = joinpath(@__DIR__, "..", "fixtures", "synthetic_sensor.csv")
    @test isfile(fixture_csv)

    # 1. SHA-256 and CSV Reader
    df, ref = CSVReader.read_csv_dataset(fixture_csv)
    @test nrow(df) == 200
    @test ncol(df) == 4
    @test ref.row_count == 200
    @test length(ref.sha256_hash) == 64
    @test haskey(ref.schema, "temperature")

    # 2. Dataset Preview
    preview = CSVReader.get_dataset_preview(df, 10)
    @test preview["total_rows"] == 200
    @test preview["preview_rows"] == 10
    @test length(preview["rows"]) == 10

    # 3. Data Profiler
    profile = DataProfiler.profile_dataset(df)
    @test profile["row_count"] == 200
    @test profile["column_count"] == 4
    @test haskey(profile["columns"], "pressure")
    col_p = profile["columns"]["pressure"]
    @test col_p.missing_count == 0
    @test col_p.min_val < col_p.max_val
    @test length(profile["numeric_columns"]) == 4

    # 4. Correlation Matrix
    corr_info = profile["correlation_matrix"]
    @test size(corr_info["matrix"]) == (4, 4)
    # Diagonal correlation must be exactly 1.0
    for i in 1:4
        @test isapprox(corr_info["matrix"][i, i], 1.0, atol=1e-5)
    end

    # 5. Deterministic Partitioning
    split1 = DataSplits.create_train_val_test_split(200; train_ratio=0.70, val_ratio=0.15, test_ratio=0.15, seed=42)
    split2 = DataSplits.create_train_val_test_split(200; train_ratio=0.70, val_ratio=0.15, test_ratio=0.15, seed=42)
    @test split1.train_indices == split2.train_indices
    @test length(split1.train_indices) == 140
    @test length(split1.val_indices) == 30
    @test length(split1.test_indices) == 30
    # No index overlap
    @test isempty(intersect(split1.train_indices, split1.val_indices))
    @test isempty(intersect(split1.train_indices, split1.test_indices))
    @test isempty(intersect(split1.val_indices, split1.test_indices))

    # 6. SQLite Persistence
    temp_db_path = tempname() * ".sqlite"
    db = DB.init_database(temp_db_path)
    @test isfile(temp_db_path)
    DB.save_project_meta(db, "TEST-PRJ", "Test Project", "Desc", dirname(temp_db_path))
    DB.save_experiment_record(db, "EXP-01", "TEST-PRJ", "Tabular", "Run 1", "COMPLETED", 42)
    DB.update_experiment_status(db, "EXP-01", "COMPLETED"; metrics_summary="{\"r2\": 0.99}")
    
    # Verify row exists
    res = DBInterface.execute(db, "SELECT status, metrics_summary FROM experiments WHERE id = 'EXP-01';") |> DataFrame
    @test nrow(res) == 1
    @test res[1, :status] == "COMPLETED"
    @test occursin("0.99", res[1, :metrics_summary])
end

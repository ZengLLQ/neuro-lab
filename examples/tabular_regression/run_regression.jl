using NeuroLab

println("===============================================================")
println("  NeuroLab — Example: Tabular Scientific Sensor Regression     ")
println("===============================================================")

data_path = joinpath(@__DIR__, "..", "..", "test", "fixtures", "synthetic_sensor.csv")
features = ["pressure", "humidity", "wind_speed"]
target = "temperature"

println("[1/3] Loading and profiling dataset: $data_path")
df, ref = CSVReader.read_csv_dataset(data_path)
println("      Samples: $(ref.row_count) | Features: $(ref.column_count)")
println("      SHA-256: $(ref.sha256_hash)")

println("\n[2/3] Training regularized Ridge baseline model...")
res = run_tabular_baseline(data_path, target, features; seed=42, lambda=0.1)

println("\n[3/3] Held-out Evaluation Split (Untouched Test Partition):")
m_test = res["test_metrics"]
println("      Test R² Score: $(round(m_test["r2"], digits=5))")
println("      Test RMSE:     $(round(m_test["rmse"], digits=5))")
println("      Test MAE:      $(round(m_test["mae"], digits=5))")
println("===============================================================")

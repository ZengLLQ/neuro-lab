using Test
using NeuroLab

@testset "Baseline Regression Scientific Tests" begin
    fixture_csv = joinpath(@__DIR__, "..", "fixtures", "synthetic_sensor.csv")
    features = ["pressure", "humidity", "wind_speed"]
    target = "temperature"

    res = run_tabular_baseline(fixture_csv, target, features; seed=42, lambda=0.1)

    @test haskey(res, "train_metrics")
    @test haskey(res, "val_metrics")
    @test haskey(res, "test_metrics")

    m_train = res["train_metrics"]
    m_val = res["val_metrics"]
    m_test = res["test_metrics"]

    # Since synthetic target is 0.025*pressure - 0.12*humidity + 0.15*wind + 15 + noise(0.05),
    # R2 should easily exceed 0.98 on untouched test set.
    @test m_test["r2"] > 0.98
    @test m_test["rmse"] < 0.10
    @test m_test["mae"] < 0.10

    # Residual count matches test set length
    y_test = res["test_ground_truth"]
    y_pred = res["test_predictions"]
    @test length(y_test) == length(y_pred)
    @test length(y_test) == 30

    # Cancellation Token Unit Test
    token = Cancellation.CancellationToken()
    @test !Cancellation.is_cancelled(token)
    Cancellation.request_cancel!(token)
    @test Cancellation.is_cancelled(token)
end

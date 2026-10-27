using Test
using HTTP
using JSON3
using NeuroLab

include("../../app/server.jl")
using .AppServer

@testset "NeuroLab Desktop Server & Endpoints Integration Test" begin
    port = 8099
    server = AppServer.start_neurolab_server(port; async_mode=true)
    base_url = "http://127.0.0.1:$port"

    try
        # 1. UI Root Test
        resp_ui = HTTP.get("$base_url/")
        @test resp_ui.status == 200
        body_ui = String(resp_ui.body)
        @test occursin("NeuroLab — Scientific Machine Learning Studio", body_ui)
        @test occursin("Data Laboratory", body_ui)
        @test occursin("Differential Equation Simulation Workspace", body_ui)

        # 2. System Diagnostics API
        resp_sys = HTTP.get("$base_url/api/system_info")
        @test resp_sys.status == 200
        sys_info = JSON3.read(String(resp_sys.body))
        @test haskey(sys_info, :julia_version)
        @test haskey(sys_info, :ram_gb)

        # 3. Dataset Ingest & Preview API
        resp_ds = HTTP.get("$base_url/api/preview_dataset")
        @test resp_ds.status == 200
        ds_info = JSON3.read(String(resp_ds.body))
        @test haskey(ds_info, :hash)
        @test ds_info.preview.total_rows == 200

        # 4. Baseline Regression ML API
        resp_base = HTTP.get("$base_url/api/run_baseline")
        @test resp_base.status == 200
        base_info = JSON3.read(String(resp_base.body))
        @test base_info.test_metrics.r2 > 0.98

        # 5. ODE Simulation API
        resp_ode = HTTP.get("$base_url/api/run_ode?system=damped&solver=Tsit5")
        @test resp_ode.status == 200
        ode_info = JSON3.read(String(resp_ode.body))
        @test ode_info.success == true
        @test ode_info.metrics.max_error_linf < 1e-5

    finally
        AppServer.stop_neurolab_server!()
    end
end

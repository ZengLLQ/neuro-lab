module AppServer

using HTTP
using JSON3
using NeuroLab
using NeuroLab.DomainTypes
using NeuroLab.Cancellation

include("ui_html.jl")
using .UIHtml

export start_neurolab_server, stop_neurolab_server!

mutable struct ServerState
    active_token::Union{CancellationToken, Nothing}
    is_running::Bool
    server_handle::Any
end

const GLOBAL_STATE = ServerState(nothing, false, nothing)

function router_handler(req::HTTP.Request)
    uri = HTTP.URI(req.target)
    path = uri.path
    query_params = HTTP.queryparams(uri)

    # 1. UI Root
    if path == "/" || path == "/index.html"
        return HTTP.Response(200, ["Content-Type" => "text/html; charset=utf-8"], get_ui_html())

    # 2. System Diagnostics Telemetry
    elseif path == "/api/system_info"
        info = Dict(
            "julia_version" => string(VERSION),
            "os" => string(Sys.KERNEL),
            "cpu_threads" => Threads.nthreads(),
            "ram_gb" => round(Sys.total_memory() / (1024^3), digits=2),
            "gpu_status" => "CPU Baseline (No GPU configured)"
        )
        return HTTP.Response(200, ["Content-Type" => "application/json"], JSON3.write(info))

    # 3. Dataset Ingest & Preview
    elseif path == "/api/preview_dataset"
        fixture_path = joinpath(@__DIR__, "..", "test", "fixtures", "synthetic_sensor.csv")
        df, ref = CSVReader.read_csv_dataset(fixture_path)
        preview = CSVReader.get_dataset_preview(df, 100)
        resp = Dict(
            "hash" => ref.sha256_hash,
            "preview" => preview
        )
        return HTTP.Response(200, ["Content-Type" => "application/json"], JSON3.write(resp))

    # 4. Run Baseline Classical ML
    elseif path == "/api/run_baseline"
        fixture_path = joinpath(@__DIR__, "..", "test", "fixtures", "synthetic_sensor.csv")
        features = ["pressure", "humidity", "wind_speed"]
        target = "temperature"
        res = run_tabular_baseline(fixture_path, target, features; seed=42, lambda=0.1)
        resp = Dict(
            "test_metrics" => res["test_metrics"],
            "test_predictions" => res["test_predictions"],
            "test_ground_truth" => res["test_ground_truth"]
        )
        return HTTP.Response(200, ["Content-Type" => "application/json"], JSON3.write(resp))

    # 5. Run ODE Numerical Simulation
    elseif path == "/api/run_ode"
        system_name = get(query_params, "system", "damped")
        solver_name = get(query_params, "solver", "Tsit5")

        spec = ODESpec(
            system_name,
            Dict("omega0" => 2.0, "gamma" => 0.2, "alpha" => 0.5),
            [1.0, 0.0],
            (0.0, 10.0),
            solver_name,
            1e-8,
            1e-6
        )
        res = ODECore.solve_ode_system(spec; saveat_points=150)
        return HTTP.Response(200, ["Content-Type" => "application/json"], JSON3.write(res))

    # 6. Run PINN Training
    elseif path == "/api/run_pinn"
        epochs_str = get(query_params, "epochs", "80")
        epochs = parse(Int, epochs_str)

        token = CancellationToken()
        GLOBAL_STATE.active_token = token

        res = PINNCore.train_damped_oscillator_pinn(
            2.0, 0.2, 1.0, 0.0;
            epochs=epochs,
            cancel_token=token
        )
        return HTTP.Response(200, ["Content-Type" => "application/json"], JSON3.write(res))

    # 7. Cancel Active Training Job
    elseif path == "/api/cancel_job"
        if GLOBAL_STATE.active_token !== nothing
            request_cancel!(GLOBAL_STATE.active_token)
        end
        return HTTP.Response(200, ["Content-Type" => "application/json"], JSON3.write(Dict("status" => "cancelling_requested")))

    else
        return HTTP.Response(404, ["Content-Type" => "text/plain"], "Not Found")
    end
end

function start_neurolab_server(port::Int=8088; async_mode::Bool=true)
    println("===============================================================")
    println("  NeuroLab — Scientific Machine Learning Desktop Server        ")
    println("  Serving local scientific interface on: http://127.0.0.1:\$port  ")
    println("===============================================================")

    server = HTTP.serve!(router_handler, "127.0.0.1", port)
    GLOBAL_STATE.server_handle = server
    GLOBAL_STATE.is_running = true

    if !async_mode
        wait(server)
    end
    return server
end

function stop_neurolab_server!()
    if GLOBAL_STATE.server_handle !== nothing
        close(GLOBAL_STATE.server_handle)
        GLOBAL_STATE.is_running = false
        println("NeuroLab Server stopped.")
    end
end

end # module AppServer

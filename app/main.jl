using NeuroLab
include("server.jl")
using .AppServer

function main()
    port = 8088
    println("[NeuroLab] Launching Scientific Studio workstation on port $port...")
    server = AppServer.start_neurolab_server(port; async_mode=true)

    # Open default OS desktop browser
    url = "http://127.0.0.1:$port"
    try
        if Sys.iswindows()
            run(`cmd /c start $url`)
        elseif Sys.isapple()
            run(`open $url`)
        elseif Sys.islinux()
            run(`xdg-open $url`)
        end
    catch e
        println("[NeuroLab] Note: Open $url in your web browser.")
    end

    println("[NeuroLab] Running. Press Ctrl+C to terminate.")
    try
        while true
            sleep(1.0)
        end
    catch e
        println("\n[NeuroLab] Shutting down workstation server...")
        AppServer.stop_neurolab_server!()
    end
end

if abspath(PROGRAM_FILE) == @__FILE__
    main()
end

module EventBusModule

using Dates
using ..DomainTypes

export JobEvent, EventBus, publish_event!, subscribe_events, close_event_bus!

struct JobEvent
    run_id::String
    timestamp::DateTime
    event_type::String # "state_changed", "metric", "log", "checkpoint"
    data::Dict{String, Any}
end

struct EventBus
    channel::Channel{JobEvent}
    listeners::Vector{Function}

    function EventBus(buffer_size::Int=1000)
        chan = Channel{JobEvent}(buffer_size)
        new(chan, Function[])
    end
end

function publish_event!(bus::EventBus, event::JobEvent)
    if isopen(bus.channel)
        # Non-blocking put if buffer full, drops oldest or skips to preserve worker performance
        try
            put!(bus.channel, event)
        catch e
            # channel closed or full
        end
    end
    for listener in bus.listeners
        try
            listener(event)
        catch
            # protect bus from broken listener
        end
    end
end

function subscribe_events(bus::EventBus, callback::Function)
    push!(bus.listeners, callback)
end

function close_event_bus!(bus::EventBus)
    if isopen(bus.channel)
        close(bus.channel)
    end
end

end # module EventBusModule

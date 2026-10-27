using Random
using CSV
using DataFrames

"""
Generates a deterministic synthetic scientific dataset:
temperature = 2.5 * pressure - 1.2 * humidity + 0.8 * wind_speed + 15.0 + noise
"""
function generate_sensor_dataset(filepath::String; n_samples::Int=200, seed::Int=42)
    rng = MersenneTwister(seed)
    
    pressures = 980.0 .+ 50.0 .* rand(rng, n_samples)
    humidities = 20.0 .+ 60.0 .* rand(rng, n_samples)
    winds = 0.0 .+ 15.0 .* rand(rng, n_samples)
    
    # Ground truth physics relation + small measurement noise
    noise = 0.05 .* randn(rng, n_samples)
    temperatures = 0.025 .* pressures .- 0.12 .* humidities .+ 0.15 .* winds .+ 15.0 .+ noise

    df = DataFrame(
        pressure = pressures,
        humidity = humidities,
        wind_speed = winds,
        temperature = temperatures
    )

    mkpath(dirname(filepath))
    CSV.write(filepath, df)
    return filepath
end

mkpath("test/fixtures")
generate_sensor_dataset("test/fixtures/synthetic_sensor.csv")

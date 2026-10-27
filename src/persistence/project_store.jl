module ProjectStore

using TOML
using JSON3
using Dates
using SHA
using ..DomainTypes

export init_project_structure, atomic_write_file, save_provenance_manifest

"""
    atomic_write_file(filepath::String, content::String)

Writes content to a temporary file before atomically renaming it, preventing corrupt writes.
"""
function atomic_write_file(filepath::String, content::String)
    dir = dirname(filepath)
    if !isdir(dir)
        mkpath(dir)
    end
    tmp_path = filepath * ".tmp"
    open(tmp_path, "w") do io
        write(io, content)
    end
    mv(tmp_path, filepath; force=true)
end

"""
    init_project_structure(project_root::String, name::String; description::String="")

Initializes standard directory tree and writes the root `project.toml`.
"""
function init_project_structure(project_root::String, name::String; description::String="")::String
    mkpath(project_root)
    mkpath(joinpath(project_root, "datasets", "source"))
    mkpath(joinpath(project_root, "datasets", "processed"))
    mkpath(joinpath(project_root, "experiments"))
    mkpath(joinpath(project_root, "exports"))

    proj_toml_path = joinpath(project_root, "project.toml")
    toml_dict = Dict(
        "project" => Dict(
            "name" => name,
            "description" => description,
            "schema_version" => "1.0",
            "created_at" => string(Dates.now()),
            "engine" => "NeuroLab Julia " * string(VERSION)
        )
    )

    open(proj_toml_path, "w") do io
        TOML.print(io, toml_dict)
    end

    return project_root
end

"""
    save_provenance_manifest(exp_dir::String, manifest::ProvenanceManifest)

Serializes the complete runtime and computational provenance into `provenance.json`.
"""
function save_provenance_manifest(exp_dir::String, manifest::ProvenanceManifest)
    manifest_path = joinpath(exp_dir, "provenance.json")
    json_str = JSON3.write(manifest)
    atomic_write_file(manifest_path, json_str)
end

end # module ProjectStore

module DB

using SQLite
using DBInterface
using Dates
using ..DomainTypes

export init_database, save_project_meta, list_projects, save_experiment_record, update_experiment_status

function init_database(db_path::String)::SQLite.DB
    db = SQLite.DB(db_path)
    # Enable WAL mode for high concurrency
    DBInterface.execute(db, "PRAGMA journal_mode=WAL;")
    DBInterface.execute(db, "PRAGMA synchronous=NORMAL;")

    # Projects Table
    DBInterface.execute(db, """
    CREATE TABLE IF NOT EXISTS projects (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        description TEXT,
        root_path TEXT NOT NULL,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
    );
    """)

    # Datasets Table
    DBInterface.execute(db, """
    CREATE TABLE IF NOT EXISTS datasets (
        id TEXT PRIMARY KEY,
        project_id TEXT,
        name TEXT NOT NULL,
        source_path TEXT NOT NULL,
        row_count INTEGER,
        column_count INTEGER,
        sha256_hash TEXT NOT NULL,
        created_at TEXT NOT NULL
    );
    """)

    # Experiments Table
    DBInterface.execute(db, """
    CREATE TABLE IF NOT EXISTS experiments (
        id TEXT PRIMARY KEY,
        project_id TEXT,
        workflow TEXT NOT NULL,
        name TEXT NOT NULL,
        status TEXT NOT NULL,
        seed INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        finished_at TEXT,
        metrics_summary TEXT
    );
    """)

    # Artifacts Table
    DBInterface.execute(db, """
    CREATE TABLE IF NOT EXISTS artifacts (
        id TEXT PRIMARY KEY,
        experiment_id TEXT NOT NULL,
        name TEXT NOT NULL,
        relative_path TEXT NOT NULL,
        media_type TEXT NOT NULL,
        byte_size INTEGER NOT NULL,
        checksum TEXT NOT NULL
    );
    """)

    return db
end

function save_project_meta(db::SQLite.DB, id::String, name::String, desc::String, root::String)
    now_str = string(Dates.now())
    stmt = DBInterface.prepare(db, """
    INSERT INTO projects (id, name, description, root_path, created_at, updated_at)
    VALUES (?, ?, ?, ?, ?, ?)
    ON CONFLICT(id) DO UPDATE SET
        name=excluded.name,
        description=excluded.description,
        updated_at=excluded.updated_at;
    """)
    DBInterface.execute(stmt, [id, name, desc, root, now_str, now_str])
end

function save_experiment_record(db::SQLite.DB, id::String, project_id::String, workflow::String, name::String, status::String, seed::Int)
    now_str = string(Dates.now())
    stmt = DBInterface.prepare(db, """
    INSERT INTO experiments (id, project_id, workflow, name, status, seed, created_at)
    VALUES (?, ?, ?, ?, ?, ?, ?)
    ON CONFLICT(id) DO UPDATE SET status=excluded.status;
    """)
    DBInterface.execute(stmt, [id, project_id, workflow, name, status, seed, now_str])
end

function update_experiment_status(db::SQLite.DB, id::String, status::String; metrics_summary::String="")
    now_str = string(Dates.now())
    stmt = DBInterface.prepare(db, """
    UPDATE experiments
    SET status = ?, finished_at = ?, metrics_summary = ?
    WHERE id = ?;
    """)
    DBInterface.execute(stmt, [status, now_str, metrics_summary, id])
end

end # module DB

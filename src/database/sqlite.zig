const std = @import("std");
const sqlite = @cImport({
    @cInclude("sqlite3.h");
});

pub const Database = struct {
    allocator: std.mem.Allocator,
    db: ?*sqlite.sqlite3,

    pub fn init(
        allocator: std.mem.Allocator,
        path: []const u8,
    ) !Database {
        var db: ?*sqlite.sqlite3 = null;

        const rc = sqlite.sqlite3_open(
            path.ptr,
            &db,
        );

        if (rc != sqlite.SQLITE_OK) {
            return error.DatabaseOpenFailed;
        }

        var database = Database{
            .allocator = allocator,
            .db = db,
        };

        try database.createTables();

        return database;
    }

    pub fn deinit(
        self: *Database,
    ) void {
        if (self.db) |db| {
            _ = sqlite.sqlite3_close(db);
        }
    }

    fn createTables(
        self: *Database,
    ) !void {
        const cache_table =
            \\CREATE TABLE IF NOT EXISTS cache (
            \\ id INTEGER PRIMARY KEY AUTOINCREMENT,
            \\ cache_key TEXT UNIQUE NOT NULL,
            \\ cache_value TEXT NOT NULL,
            \\ created_at INTEGER NOT NULL,
            \\ expires_at INTEGER NOT NULL
            \\);
        ;

        try self.exec(cache_table);

        const stats_table =
            \\CREATE TABLE IF NOT EXISTS stats (
            \\ id INTEGER PRIMARY KEY AUTOINCREMENT,
            \\ command_name TEXT NOT NULL,
            \\ total_calls INTEGER DEFAULT 0,
            \\ last_used INTEGER
            \\);
        ;

        try self.exec(stats_table);
    }

    pub fn exec(
        self: *Database,
        sql: []const u8,
    ) !void {
        var err_msg: ?[*:0]u8 = null;

        const rc = sqlite.sqlite3_exec(
            self.db,
            sql.ptr,
            null,
            null,
            &err_msg,
        );

        if (rc != sqlite.SQLITE_OK) {
            if (err_msg != null) {
                sqlite.sqlite3_free(err_msg);
            }

            return error.SqlExecutionFailed;
        }
    }

    pub fn setCache(
        self: *Database,
        key: []const u8,
        value: []const u8,
        ttl_seconds: i64,
    ) !void {
        const now = std.time.timestamp();

        const expires_at = now + ttl_seconds;

        const sql =
            \\INSERT OR REPLACE INTO cache
            \\(
            \\ cache_key,
            \\ cache_value,
            \\ created_at,
            \\ expires_at
            \\)
            \\VALUES (?1, ?2, ?3, ?4);
        ;

        var stmt: ?*sqlite.sqlite3_stmt = null;

        if (sqlite.sqlite3_prepare_v2(
            self.db,
            sql.ptr,
            -1,
            &stmt,
            null,
        ) != sqlite.SQLITE_OK) {
            return error.StatementPrepareFailed;
        }

        defer _ = sqlite.sqlite3_finalize(stmt);

        _ = sqlite.sqlite3_bind_text(
            stmt,
            1,
            key.ptr,
            @intCast(key.len),
            sqlite.SQLITE_TRANSIENT,
        );

        _ = sqlite.sqlite3_bind_text(
            stmt,
            2,
            value.ptr,
            @intCast(value.len),
            sqlite.SQLITE_TRANSIENT,
        );

        _ = sqlite.sqlite3_bind_int64(
            stmt,
            3,
            now,
        );

        _ = sqlite.sqlite3_bind_int64(
            stmt,
            4,
            expires_at,
        );

        if (sqlite.sqlite3_step(stmt) != sqlite.SQLITE_DONE) {
            return error.InsertFailed;
        }
    }

    pub fn getCache(
        self: *Database,
        key: []const u8,
    ) !?[]u8 {
        const sql =
            \\SELECT cache_value, expires_at
            \\FROM cache
            \\WHERE cache_key = ?1;
        ;

        var stmt: ?*sqlite.sqlite3_stmt = null;

        if (sqlite.sqlite3_prepare_v2(
            self.db,
            sql.ptr,
            -1,
            &stmt,
            null,
        ) != sqlite.SQLITE_OK) {
            return error.StatementPrepareFailed;
        }

        defer _ = sqlite.sqlite3_finalize(stmt);

        _ = sqlite.sqlite3_bind_text(
            stmt,
            1,
            key.ptr,
            @intCast(key.len),
            sqlite.SQLITE_TRANSIENT,
        );

        const result = sqlite.sqlite3_step(stmt);

        if (result != sqlite.SQLITE_ROW) {
            return null;
        }

        const expires_at = sqlite.sqlite3_column_int64(
            stmt,
            1,
        );

        if (std.time.timestamp() > expires_at) {
            return null;
        }

        const text_ptr =
            sqlite.sqlite3_column_text(stmt, 0);

        const len =
            sqlite.sqlite3_column_bytes(stmt, 0);

        const slice =
            text_ptr[0..@intCast(len)];

        return try self.allocator.dupe(
            u8,
            slice,
        );
    }

    pub fn deleteExpiredCache(
        self: *Database,
    ) !void {
        const sql =
            \\DELETE FROM cache
            \\WHERE expires_at < strftime('%s','now');
        ;

        try self.exec(sql);
    }

    pub fn incrementStat(
        self: *Database,
        command_name: []const u8,
    ) !void {
        const sql =
            \\INSERT INTO stats
            \\(
            \\ command_name,
            \\ total_calls,
            \\ last_used
            \\)
            \\VALUES
            \\(
            \\ ?1,
            \\ 1,
            \\ ?2
            \\)
            \\ON CONFLICT(command_name)
            \\DO UPDATE SET
            \\ total_calls = total_calls + 1,
            \\ last_used = excluded.last_used;
        ;

        var stmt: ?*sqlite.sqlite3_stmt = null;

        if (sqlite.sqlite3_prepare_v2(
            self.db,
            sql.ptr,
            -1,
            &stmt,
            null,
        ) != sqlite.SQLITE_OK) {
            return error.StatementPrepareFailed;
        }

        defer _ = sqlite.sqlite3_finalize(stmt);

        _ = sqlite.sqlite3_bind_text(
            stmt,
            1,
            command_name.ptr,
            @intCast(command_name.len),
            sqlite.SQLITE_TRANSIENT,
        );

        _ = sqlite.sqlite3_bind_int64(
            stmt,
            2,
            std.time.timestamp(),
        );

        _ = sqlite.sqlite3_step(stmt);
    }
};
const std = @import("std");

pub const Config = struct {
    allocator: std.mem.Allocator,

    // Discord
    discord_token: []const u8,
    application_id: []const u8,
    guild_id: []const u8,

    // RAWG
    rawg_api_key: []const u8,

    // IGDB
    igdb_client_id: []const u8,
    igdb_access_token: []const u8,

    // Database
    database_path: []const u8,

    // Cache
    cache_ttl_hours: u32,

    pub fn deinit(self: *Config) void {
        self.allocator.free(self.discord_token);
        self.allocator.free(self.application_id);
        self.allocator.free(self.guild_id);

        self.allocator.free(self.rawg_api_key);

        self.allocator.free(self.igdb_client_id);
        self.allocator.free(self.igdb_access_token);

        self.allocator.free(self.database_path);
    }
};

pub fn load(
    allocator: std.mem.Allocator,
) !Config {
    return Config{
        .allocator = allocator,

        .discord_token = try getEnv(
            allocator,
            "DISCORD_TOKEN",
        ),

        .application_id = try getEnv(
            allocator,
            "DISCORD_APPLICATION_ID",
        ),

        .guild_id = try getEnvOrDefault(
            allocator,
            "DISCORD_GUILD_ID",
            "",
        ),

        .rawg_api_key = try getEnv(
            allocator,
            "RAWG_API_KEY",
        ),

        .igdb_client_id = try getEnvOrDefault(
            allocator,
            "IGDB_CLIENT_ID",
            "",
        ),

        .igdb_access_token = try getEnvOrDefault(
            allocator,
            "IGDB_ACCESS_TOKEN",
            "",
        ),

        .database_path = try getEnvOrDefault(
            allocator,
            "DATABASE_PATH",
            "data/bot.db",
        ),

        .cache_ttl_hours = try getEnvInt(
            allocator,
            "CACHE_TTL_HOURS",
            24,
        ),
    };
}

fn getEnv(
    allocator: std.mem.Allocator,
    name: []const u8,
) ![]const u8 {
    return try std.process.getEnvVarOwned(
        allocator,
        name,
    );
}

fn getEnvOrDefault(
    allocator: std.mem.Allocator,
    name: []const u8,
    default_value: []const u8,
) ![]const u8 {
    return std.process.getEnvVarOwned(
        allocator,
        name,
    ) catch try allocator.dupe(
        u8,
        default_value,
    );
}

fn getEnvInt(
    allocator: std.mem.Allocator,
    name: []const u8,
    default_value: u32,
) !u32 {
    const value = std.process.getEnvVarOwned(
        allocator,
        name,
    ) catch return default_value;

    defer allocator.free(value);

    return std.fmt.parseInt(
        u32,
        value,
        10,
    ) catch default_value;
}

pub fn validate(
    config: *const Config,
) !void {
    if (config.discord_token.len == 0)
        return error.MissingDiscordToken;

    if (config.application_id.len == 0)
        return error.MissingApplicationId;

    if (config.rawg_api_key.len == 0)
        return error.MissingRawgApiKey;
}
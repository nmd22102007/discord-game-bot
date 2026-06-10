const std = @import("std");

pub const Config = struct {
    allocator: std.mem.Allocator,
    discord_token: []const u8,

    pub fn deinit(self: Config) void {
        self.allocator.free(self.discord_token);
    }
};

pub fn load(allocator: std.mem.Allocator) !Config {
    const token = try std.process.getEnvVarOwned(
        allocator,
        "DISCORD_TOKEN",
    );

    return Config{
        .allocator = allocator,
        .discord_token = token,
    };
}
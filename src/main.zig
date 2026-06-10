const std = @import("std");

const Config = @import("utils/config.zig");
const Logger = @import("utils/logger.zig");

const DiscordService = @import("services/discord.zig");

pub fn main() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    const allocator = gpa.allocator();

    Logger.info("=================================");
    Logger.info("Discord Game Bot Starting...");
    Logger.info("=================================");

    // Load .env / config
    const config = try Config.load(allocator);
    defer config.deinit();

    Logger.info("Configuration loaded.");

    if (config.discord_token.len == 0) {
        Logger.err("DISCORD_TOKEN is missing.");
        return error.MissingDiscordToken;
    }

    // Create Discord client
    var discord = try DiscordService.init(
        allocator,
        config.discord_token,
    );
    defer discord.deinit();

    Logger.info("Connecting to Discord...");

    try discord.connect();

    Logger.info("Bot is online.");

    // Register slash commands
    try discord.registerCommands();

    Logger.info("Slash commands registered.");

    // Event loop
    try discord.run();

    Logger.info("Bot shutting down.");
}
const std = @import("std");

const RawgService = @import("../services/rawg.zig");
const Game = @import("../models/game.zig").Game;

pub const GameCommand = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) GameCommand {
        return .{
            .allocator = allocator,
        };
    }

    pub fn execute(
        self: *GameCommand,
        game_name: []const u8,
    ) ![]u8 {
        var rawg = RawgService.init(self.allocator);
        defer rawg.deinit();

        const game = try rawg.searchGame(game_name);

        return try self.buildEmbed(game);
    }

    fn buildEmbed(
        self: *GameCommand,
        game: Game,
    ) ![]u8 {
        var list = std.ArrayList(u8).init(self.allocator);
        errdefer list.deinit();

        const writer = list.writer();

        try writer.print(
            "🎮 {s}\n\n",
            .{game.name},
        );

        try writer.print(
            "⭐ Rating: {d:.1}/5\n",
            .{game.rating},
        );

        try writer.print(
            "📅 Release Date: {s}\n",
            .{game.release_date},
        );

        try writer.print(
            "🏢 Developer(s):\n",
            .{},
        );

        for (game.developers) |dev| {
            try writer.print(
                "- {s}\n",
                .{dev},
            );
        }

        try writer.print(
            "\n📦 Publisher(s):\n",
            .{},
        );

        for (game.publishers) |pub| {
            try writer.print(
                "- {s}\n",
                .{pub},
            );
        }

        try writer.print(
            "\n🎯 Genres:\n",
            .{},
        );

        for (game.genres) |genre| {
            try writer.print(
                "- {s}\n",
                .{genre},
            );
        }

        try writer.print(
            "\n🖥 Platforms:\n",
            .{},
        );

        for (game.platforms) |platform| {
            try writer.print(
                "- {s}\n",
                .{platform},
            );
        }

        if (game.description.len > 0) {
            try writer.print(
                "\n📖 Description:\n{s}\n",
                .{game.description},
            );
        }

        try writer.print(
            "\n🖼 Cover:\n{s}\n",
            .{game.logo_url},
        );

        if (game.screenshots.len > 0) {
            try writer.print(
                "\n📸 Screenshots:\n",
                .{},
            );

            for (game.screenshots) |shot| {
                try writer.print(
                    "{s}\n",
                    .{shot},
                );
            }
        }

        try writer.print(
            "\nPowered by RAWG API",
            .{},
        );

        return list.toOwnedSlice();
    }
};
const std = @import("std");

const RawgService = @import("../services/rawg.zig");
const Game = @import("../models/game.zig").Game;

pub const TrendingCommand = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) TrendingCommand {
        return .{
            .allocator = allocator,
        };
    }

    pub fn execute(self: *TrendingCommand) ![]u8 {
        var rawg = RawgService.init(self.allocator);
        defer rawg.deinit();

        const games = try rawg.getTrendingGames();

        return try self.buildTrendingEmbed(games);
    }

    fn buildTrendingEmbed(
        self: *TrendingCommand,
        games: []Game,
    ) ![]u8 {
        var list = std.ArrayList(u8).init(self.allocator);
        errdefer list.deinit();

        const writer = list.writer();

        try writer.writeAll(
            "🔥 TRENDING GAMES\n\n",
        );

        if (games.len == 0) {
            try writer.writeAll(
                "No trending games found.\n",
            );

            return list.toOwnedSlice();
        }

        for (games, 0..) |game, index| {
            try writer.print(
                "#{d} 🎮 {s}\n",
                .{
                    index + 1,
                    game.name,
                },
            );

            try writer.print(
                "⭐ Rating: {d:.1}/5\n",
                .{game.rating},
            );

            try writer.print(
                "📅 Released: {s}\n",
                .{game.release_date},
            );

            if (game.genres.len > 0) {
                try writer.writeAll(
                    "🎯 Genres: ",
                );

                for (game.genres, 0..) |genre, i| {
                    if (i > 0)
                        try writer.writeAll(", ");

                    try writer.writeAll(genre);
                }

                try writer.writeAll("\n");
            }

            try writer.writeAll("\n");
        }

        try writer.writeAll(
            "Powered by RAWG API",
        );

        return list.toOwnedSlice();
    }
};
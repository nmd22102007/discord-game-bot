const std = @import("std");

const RawgService = @import("../services/rawg.zig");
const Game = @import("../models/game.zig").Game;

pub const CompareCommand = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) CompareCommand {
        return .{
            .allocator = allocator,
        };
    }

    pub fn execute(
        self: *CompareCommand,
        game_a_name: []const u8,
        game_b_name: []const u8,
    ) ![]u8 {
        var rawg = RawgService.init(self.allocator);
        defer rawg.deinit();

        const game_a = try rawg.searchGame(game_a_name);
        const game_b = try rawg.searchGame(game_b_name);

        return try self.buildComparison(game_a, game_b);
    }

    fn buildComparison(
        self: *CompareCommand,
        game_a: Game,
        game_b: Game,
    ) ![]u8 {
        var list = std.ArrayList(u8).init(self.allocator);
        errdefer list.deinit();

        const writer = list.writer();

        try writer.print(
            "⚔️ GAME COMPARISON\n\n",
            .{},
        );

        try writer.print(
            "🎮 {s}\nvs\n🎮 {s}\n\n",
            .{
                game_a.name,
                game_b.name,
            },
        );

        try writer.print(
            "⭐ Rating\n{s}: {d:.1}/5\n{s}: {d:.1}/5\n\n",
            .{
                game_a.name,
                game_a.rating,
                game_b.name,
                game_b.rating,
            },
        );

        try writer.print(
            "📅 Release Date\n{s}: {s}\n{s}: {s}\n\n",
            .{
                game_a.name,
                game_a.release_date,
                game_b.name,
                game_b.release_date,
            },
        );

        try writer.print(
            "🏢 Developers\n{s}: ",
            .{game_a.name},
        );

        for (game_a.developers, 0..) |dev, i| {
            if (i > 0) try writer.writeAll(", ");
            try writer.writeAll(dev);
        }

        try writer.print(
            "\n{s}: ",
            .{game_b.name},
        );

        for (game_b.developers, 0..) |dev, i| {
            if (i > 0) try writer.writeAll(", ");
            try writer.writeAll(dev);
        }

        try writer.writeAll("\n\n");

        try writer.print(
            "📦 Publishers\n{s}: ",
            .{game_a.name},
        );

        for (game_a.publishers, 0..) |pub, i| {
            if (i > 0) try writer.writeAll(", ");
            try writer.writeAll(pub);
        }

        try writer.print(
            "\n{s}: ",
            .{game_b.name},
        );

        for (game_b.publishers, 0..) |pub, i| {
            if (i > 0) try writer.writeAll(", ");
            try writer.writeAll(pub);
        }

        try writer.writeAll("\n\n");

        try writer.print(
            "🎯 Genres\n{s}: ",
            .{game_a.name},
        );

        for (game_a.genres, 0..) |genre, i| {
            if (i > 0) try writer.writeAll(", ");
            try writer.writeAll(genre);
        }

        try writer.print(
            "\n{s}: ",
            .{game_b.name},
        );

        for (game_b.genres, 0..) |genre, i| {
            if (i > 0) try writer.writeAll(", ");
            try writer.writeAll(genre);
        }

        try writer.writeAll("\n\n");

        try writer.print(
            "🖥 Platforms\n{s}: ",
            .{game_a.name},
        );

        for (game_a.platforms, 0..) |platform, i| {
            if (i > 0) try writer.writeAll(", ");
            try writer.writeAll(platform);
        }

        try writer.print(
            "\n{s}: ",
            .{game_b.name},
        );

        for (game_b.platforms, 0..) |platform, i| {
            if (i > 0) try writer.writeAll(", ");
            try writer.writeAll(platform);
        }

        try writer.writeAll("\n\n");

        if (game_a.rating > game_b.rating) {
            try writer.print(
                "🏆 Winner: {s}\n",
                .{game_a.name},
            );
        } else if (game_b.rating > game_a.rating) {
            try writer.print(
                "🏆 Winner: {s}\n",
                .{game_b.name},
            );
        } else {
            try writer.writeAll(
                "🤝 Result: Tie\n",
            );
        }

        try writer.writeAll(
            "\nPowered by RAWG API",
        );

        return list.toOwnedSlice();
    }
};
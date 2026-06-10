const std = @import("std");

const RawgService = @import("../services/rawg.zig");
const Game = @import("../models/game.zig").Game;

pub const RatingCommand = struct {
    allocator: std.mem.Allocator,

    pub fn init(allocator: std.mem.Allocator) RatingCommand {
        return .{
            .allocator = allocator,
        };
    }

    pub fn execute(
        self: *RatingCommand,
        game_name: []const u8,
    ) ![]u8 {
        var rawg = RawgService.init(self.allocator);
        defer rawg.deinit();

        const game = try rawg.searchGame(game_name);

        return try self.buildRatingEmbed(game);
    }

    fn buildRatingEmbed(
        self: *RatingCommand,
        game: Game,
    ) ![]u8 {
        var list = std.ArrayList(u8).init(self.allocator);
        errdefer list.deinit();

        const writer = list.writer();

        const stars = self.ratingStars(game.rating);

        try writer.print(
            "⭐ GAME RATING\n\n",
            .{},
        );

        try writer.print(
            "🎮 {s}\n\n",
            .{game.name},
        );

        try writer.print(
            "⭐ Rating: {d:.1}/5\n",
            .{game.rating},
        );

        try writer.print(
            "🌟 Score: {s}\n",
            .{stars},
        );

        try writer.print(
            "📅 Released: {s}\n",
            .{game.release_date},
        );

        if (game.genres.len > 0) {
            try writer.writeAll("\n🎯 Genres: ");

            for (game.genres, 0..) |genre, i| {
                if (i > 0) try writer.writeAll(", ");
                try writer.writeAll(genre);
            }

            try writer.writeAll("\n");
        }

        try writer.print(
            "\n🖼 Cover:\n{s}\n",
            .{game.logo_url},
        );

        try writer.writeAll(
            "\nPowered by RAWG API",
        );

        return list.toOwnedSlice();
    }

    fn ratingStars(
        self: *RatingCommand,
        rating: f32,
    ) []const u8 {
        _ = self;

        if (rating >= 4.8) return "★★★★★";
        if (rating >= 4.0) return "★★★★☆";
        if (rating >= 3.0) return "★★★☆☆";
        if (rating >= 2.0) return "★★☆☆☆";

        return "★☆☆☆☆";
    }
};
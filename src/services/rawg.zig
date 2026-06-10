const std = @import("std");
const Game = @import("../models/game.zig").Game;

pub const RawgService = struct {
    allocator: std.mem.Allocator,
    api_key: []const u8,
    client: std.http.Client,

    pub fn init(
        allocator: std.mem.Allocator,
        api_key: []const u8,
    ) RawgService {
        return .{
            .allocator = allocator,
            .api_key = api_key,
            .client = .{ .allocator = allocator },
        };
    }

    pub fn deinit(self: *RawgService) void {
        self.client.deinit();
    }

    pub fn searchGame(
        self: *RawgService,
        game_name: []const u8,
    ) !Game {
        const url = try std.fmt.allocPrint(
            self.allocator,
            "https://api.rawg.io/api/games?key={s}&search={s}&page_size=1",
            .{
                self.api_key,
                game_name,
            },
        );
        defer self.allocator.free(url);

        const body = try self.fetch(url);
        defer self.allocator.free(body);

        return try self.parseSearchResult(body);
    }

    pub fn getGameById(
        self: *RawgService,
        game_id: i64,
    ) !Game {
        const url = try std.fmt.allocPrint(
            self.allocator,
            "https://api.rawg.io/api/games/{d}?key={s}",
            .{
                game_id,
                self.api_key,
            },
        );
        defer self.allocator.free(url);

        const body = try self.fetch(url);
        defer self.allocator.free(body);

        return try self.parseGameDetails(body);
    }

    pub fn getTrendingGames(
        self: *RawgService,
    ) ![]Game {
        const url = try std.fmt.allocPrint(
            self.allocator,
            "https://api.rawg.io/api/games?key={s}&ordering=-rating&page_size=10",
            .{
                self.api_key,
            },
        );
        defer self.allocator.free(url);

        const body = try self.fetch(url);
        defer self.allocator.free(body);

        return try self.parseTrendingGames(body);
    }

    fn fetch(
        self: *RawgService,
        url: []const u8,
    ) ![]u8 {
        var response = std.ArrayList(u8).init(self.allocator);
        errdefer response.deinit();

        const uri = try std.Uri.parse(url);

        var req = try self.client.open(
            .GET,
            uri,
            .{},
        );
        defer req.deinit();

        try req.send();
        try req.finish();
        try req.wait();

        try req.reader().readAllArrayList(
            &response,
            1024 * 1024 * 10,
        );

        return response.toOwnedSlice();
    }

    fn parseSearchResult(
        self: *RawgService,
        json_data: []const u8,
    ) !Game {
        _ = self;
        _ = json_data;

        // TODO:
        // Parse RAWG search response
        // Extract first result
        // Return Game struct

        return error.NotImplemented;
    }

    fn parseGameDetails(
        self: *RawgService,
        json_data: []const u8,
    ) !Game {
        _ = self;
        _ = json_data;

        // TODO:
        // Parse detailed game information

        return error.NotImplemented;
    }

    fn parseTrendingGames(
        self: *RawgService,
        json_data: []const u8,
    ) ![]Game {
        _ = self;
        _ = json_data;

        // TODO:
        // Parse top 10 games

        return error.NotImplemented;
    }
};
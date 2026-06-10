const std = @import("std");
const Game = @import("../models/game.zig").Game;

pub const IgdbService = struct {
    allocator: std.mem.Allocator,
    client_id: []const u8,
    access_token: []const u8,
    client: std.http.Client,

    pub fn init(
        allocator: std.mem.Allocator,
        client_id: []const u8,
        access_token: []const u8,
    ) IgdbService {
        return .{
            .allocator = allocator,
            .client_id = client_id,
            .access_token = access_token,
            .client = .{
                .allocator = allocator,
            },
        };
    }

    pub fn deinit(self: *IgdbService) void {
        self.client.deinit();
    }

    pub fn searchGame(
        self: *IgdbService,
        game_name: []const u8,
    ) !Game {
        const query = try std.fmt.allocPrint(
            self.allocator,
            \\search "{s}";
            \\fields
            \\id,
            \\name,
            \\summary,
            \\first_release_date,
            \\rating,
            \\cover.image_id,
            \\genres.name,
            \\platforms.name,
            \\involved_companies.company.name;
            \\limit 1;
        ,
            .{game_name},
        );
        defer self.allocator.free(query);

        const body = try self.postRequest(query);
        defer self.allocator.free(body);

        return try self.parseGame(body);
    }

    pub fn getTrendingGames(
        self: *IgdbService,
    ) ![]Game {
        const query =
            \\fields
            \\id,
            \\name,
            \\rating,
            \\first_release_date,
            \\cover.image_id;
            \\sort rating desc;
            \\limit 10;
        ;

        const body = try self.postRequest(query);
        defer self.allocator.free(body);

        return try self.parseGames(body);
    }

    fn postRequest(
        self: *IgdbService,
        query: []const u8,
    ) ![]u8 {
        const url = "https://api.igdb.com/v4/games";

        var response = std.ArrayList(u8).init(self.allocator);
        errdefer response.deinit();

        const uri = try std.Uri.parse(url);

        var headers = std.http.Headers.init(self.allocator);
        defer headers.deinit();

        try headers.append(
            "Client-ID",
            self.client_id,
        );

        try headers.append(
            "Authorization",
            try std.fmt.allocPrint(
                self.allocator,
                "Bearer {s}",
                .{self.access_token},
            ),
        );

        var req = try self.client.open(
            .POST,
            uri,
            .{
                .extra_headers = headers.items,
            },
        );
        defer req.deinit();

        try req.send();

        try req.writeAll(query);

        try req.finish();
        try req.wait();

        try req.reader().readAllArrayList(
            &response,
            1024 * 1024 * 5,
        );

        return response.toOwnedSlice();
    }

    fn parseGame(
        self: *IgdbService,
        json_data: []const u8,
    ) !Game {
        _ = self;
        _ = json_data;

        return error.NotImplemented;
    }

    fn parseGames(
        self: *IgdbService,
        json_data: []const u8,
    ) ![]Game {
        _ = self;
        _ = json_data;

        return error.NotImplemented;
    }

    pub fn buildCoverUrl(
        allocator: std.mem.Allocator,
        image_id: []const u8,
    ) ![]u8 {
        return std.fmt.allocPrint(
            allocator,
            "https://images.igdb.com/igdb/image/upload/t_cover_big/{s}.jpg",
            .{image_id},
        );
    }

    pub fn buildScreenshotUrl(
        allocator: std.mem.Allocator,
        image_id: []const u8,
    ) ![]u8 {
        return std.fmt.allocPrint(
            allocator,
            "https://images.igdb.com/igdb/image/upload/t_screenshot_big/{s}.jpg",
            .{image_id},
        );
    }
};
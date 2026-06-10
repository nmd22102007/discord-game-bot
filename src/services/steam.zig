const std = @import("std");

pub const SteamGame = struct {
    app_id: u32,
    name: []const u8,
    short_description: []const u8,
    release_date: []const u8,
    developers: [][]const u8,
    publishers: [][]const u8,
    header_image: []const u8,
    website: []const u8,
    price: []const u8,
    platforms_windows: bool,
    platforms_mac: bool,
    platforms_linux: bool,
};

pub const SteamService = struct {
    allocator: std.mem.Allocator,
    client: std.http.Client,

    pub fn init(
        allocator: std.mem.Allocator,
    ) SteamService {
        return .{
            .allocator = allocator,
            .client = .{
                .allocator = allocator,
            },
        };
    }

    pub fn deinit(self: *SteamService) void {
        self.client.deinit();
    }

    pub fn getAppDetails(
        self: *SteamService,
        app_id: u32,
    ) ![]u8 {
        const url = try std.fmt.allocPrint(
            self.allocator,
            "https://store.steampowered.com/api/appdetails?appids={d}",
            .{app_id},
        );
        defer self.allocator.free(url);

        return try self.fetch(url);
    }

    pub fn getAppList(
        self: *SteamService,
    ) ![]u8 {
        return try self.fetch(
            "https://api.steampowered.com/ISteamApps/GetAppList/v2/"
        );
    }

    pub fn searchGame(
        self: *SteamService,
        game_name: []const u8,
    ) ![]u8 {
        const apps_json = try self.getAppList();
        defer self.allocator.free(apps_json);

        _ = game_name;

        // TODO:
        // Parse app list
        // Find matching game
        // Get app details

        return error.NotImplemented;
    }

    pub fn getTopSellers(
        self: *SteamService,
    ) ![]u8 {
        return error.NotImplemented;
    }

    pub fn getPopularGames(
        self: *SteamService,
    ) ![]u8 {
        return error.NotImplemented;
    }

    fn fetch(
        self: *SteamService,
        url: []const u8,
    ) ![]u8 {
        var response = std.ArrayList(u8).init(
            self.allocator,
        );
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
            10 * 1024 * 1024,
        );

        return response.toOwnedSlice();
    }

    pub fn buildStoreUrl(
        allocator: std.mem.Allocator,
        app_id: u32,
    ) ![]u8 {
        return std.fmt.allocPrint(
            allocator,
            "https://store.steampowered.com/app/{d}",
            .{app_id},
        );
    }

    pub fn buildSteamDbUrl(
        allocator: std.mem.Allocator,
        app_id: u32,
    ) ![]u8 {
        return std.fmt.allocPrint(
            allocator,
            "https://steamdb.info/app/{d}",
            .{app_id},
        );
    }
};
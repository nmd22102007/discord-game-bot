const std = @import("std");

pub const Game = struct {
    // Core Information
    id: i64 = 0,
    name: []const u8 = "",

    // Metadata
    description: []const u8 = "",
    short_description: []const u8 = "",

    // Release Info
    release_date: []const u8 = "",

    // Ratings
    rating: f32 = 0.0,
    rating_count: u32 = 0,

    // Companies
    developers: [][]const u8 = &[_][]const u8{},
    publishers: [][]const u8 = &[_][]const u8{},

    // Categories
    genres: [][]const u8 = &[_][]const u8{},
    platforms: [][]const u8 = &[_][]const u8{},

    // Images
    logo_url: []const u8 = "",
    cover_url: []const u8 = "",
    background_url: []const u8 = "",

    screenshots: [][]const u8 = &[_][]const u8{},

    // Steam Data
    steam_app_id: ?u32 = null,
    steam_url: []const u8 = "",
    steam_price: []const u8 = "",
    steam_discount: u8 = 0,

    // Links
    website: []const u8 = "",

    // Dates
    created_at: i64 = 0,
    updated_at: i64 = 0,

    pub fn init() Game {
        return .{};
    }

    pub fn hasScreenshots(
        self: *const Game,
    ) bool {
        return self.screenshots.len > 0;
    }

    pub fn hasCover(
        self: *const Game,
    ) bool {
        return self.cover_url.len > 0;
    }

    pub fn hasLogo(
        self: *const Game,
    ) bool {
        return self.logo_url.len > 0;
    }

    pub fn hasPrice(
        self: *const Game,
    ) bool {
        return self.steam_price.len > 0;
    }

    pub fn isRated(
        self: *const Game,
    ) bool {
        return self.rating > 0;
    }

    pub fn ratingStars(
        self: *const Game,
    ) []const u8 {
        if (self.rating >= 4.8)
            return "★★★★★";

        if (self.rating >= 4.0)
            return "★★★★☆";

        if (self.rating >= 3.0)
            return "★★★☆☆";

        if (self.rating >= 2.0)
            return "★★☆☆☆";

        return "★☆☆☆☆";
    }

    pub fn deinit(
        self: *Game,
        allocator: std.mem.Allocator,
    ) void {
        allocator.free(self.name);
        allocator.free(self.description);
        allocator.free(self.short_description);

        allocator.free(self.release_date);

        allocator.free(self.logo_url);
        allocator.free(self.cover_url);
        allocator.free(self.background_url);

        allocator.free(self.website);
        allocator.free(self.steam_url);
        allocator.free(self.steam_price);

        for (self.developers) |item| {
            allocator.free(item);
        }

        allocator.free(self.developers);

        for (self.publishers) |item| {
            allocator.free(item);
        }

        allocator.free(self.publishers);

        for (self.genres) |item| {
            allocator.free(item);
        }

        allocator.free(self.genres);

        for (self.platforms) |item| {
            allocator.free(item);
        }

        allocator.free(self.platforms);

        for (self.screenshots) |item| {
            allocator.free(item);
        }

        allocator.free(self.screenshots);
    }
};
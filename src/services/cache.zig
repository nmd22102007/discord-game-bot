const std = @import("std");

pub const CacheEntry = struct {
    data: []u8,
    created_at: i64,
    expires_at: i64,
};

pub const CacheService = struct {
    allocator: std.mem.Allocator,
    map: std.StringHashMap(CacheEntry),

    pub fn init(
        allocator: std.mem.Allocator,
    ) CacheService {
        return .{
            .allocator = allocator,
            .map = std.StringHashMap(CacheEntry).init(
                allocator,
            ),
        };
    }

    pub fn deinit(
        self: *CacheService,
    ) void {
        var iterator = self.map.iterator();

        while (iterator.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.data);
        }

        self.map.deinit();
    }

    pub fn set(
        self: *CacheService,
        key: []const u8,
        value: []const u8,
        ttl_seconds: i64,
    ) !void {
        const now = std.time.timestamp();

        const key_copy = try self.allocator.dupe(
            u8,
            key,
        );

        const value_copy = try self.allocator.dupe(
            u8,
            value,
        );

        try self.map.put(
            key_copy,
            CacheEntry{
                .data = value_copy,
                .created_at = now,
                .expires_at = now + ttl_seconds,
            },
        );
    }

    pub fn get(
        self: *CacheService,
        key: []const u8,
    ) ?[]const u8 {
        const entry = self.map.getPtr(key) orelse
            return null;

        const now = std.time.timestamp();

        if (now > entry.expires_at) {
            return null;
        }

        return entry.data;
    }

    pub fn exists(
        self: *CacheService,
        key: []const u8,
    ) bool {
        return self.get(key) != null;
    }

    pub fn remove(
        self: *CacheService,
        key: []const u8,
    ) bool {
        if (self.map.fetchRemove(key)) |entry| {
            self.allocator.free(entry.key);
            self.allocator.free(entry.value.data);
            return true;
        }

        return false;
    }

    pub fn clear(
        self: *CacheService,
    ) void {
        var iterator = self.map.iterator();

        while (iterator.next()) |entry| {
            self.allocator.free(entry.key_ptr.*);
            self.allocator.free(entry.value_ptr.data);
        }

        self.map.clearRetainingCapacity();
    }

    pub fn cleanupExpired(
        self: *CacheService,
    ) void {
        var expired_keys = std.ArrayList([]const u8)
            .init(self.allocator);
        defer expired_keys.deinit();

        var iterator = self.map.iterator();

        const now = std.time.timestamp();

        while (iterator.next()) |entry| {
            if (now > entry.value_ptr.expires_at) {
                expired_keys.append(
                    entry.key_ptr.*
                ) catch {};
            }
        }

        for (expired_keys.items) |key| {
            _ = self.remove(key);
        }
    }

    pub fn size(
        self: *CacheService,
    ) usize {
        return self.map.count();
    }

    pub fn cacheGameSearch(
        self: *CacheService,
        game_name: []const u8,
        json: []const u8,
    ) !void {
        try self.set(
            game_name,
            json,
            86400, // 24h
        );
    }

    pub fn cacheGameDetails(
        self: *CacheService,
        game_id: i64,
        json: []const u8,
    ) !void {
        const key = try std.fmt.allocPrint(
            self.allocator,
            "game:{d}",
            .{game_id},
        );
        defer self.allocator.free(key);

        try self.set(
            key,
            json,
            86400,
        );
    }

    pub fn cacheTrending(
        self: *CacheService,
        json: []const u8,
    ) !void {
        try self.set(
            "trending",
            json,
            3600,
        );
    }

    pub fn getTrending(
        self: *CacheService,
    ) ?[]const u8 {
        return self.get("trending");
    }
};
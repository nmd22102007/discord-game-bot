const std = @import("std");

pub const LogLevel = enum {
    debug,
    info,
    warn,
    err,
};

pub const Logger = struct {
    pub fn debug(message: []const u8) void {
        log(.debug, message);
    }

    pub fn info(message: []const u8) void {
        log(.info, message);
    }

    pub fn warn(message: []const u8) void {
        log(.warn, message);
    }

    pub fn err(message: []const u8) void {
        log(.err, message);
    }

    pub fn debugf(
        comptime fmt: []const u8,
        args: anytype,
    ) void {
        logf(.debug, fmt, args);
    }

    pub fn infof(
        comptime fmt: []const u8,
        args: anytype,
    ) void {
        logf(.info, fmt, args);
    }

    pub fn warnf(
        comptime fmt: []const u8,
        args: anytype,
    ) void {
        logf(.warn, fmt, args);
    }

    pub fn errf(
        comptime fmt: []const u8,
        args: anytype,
    ) void {
        logf(.err, fmt, args);
    }

    fn log(
        level: LogLevel,
        message: []const u8,
    ) void {
        const timestamp = std.time.timestamp();

        std.debug.print(
            "[{d}] [{s}] {s}\n",
            .{
                timestamp,
                levelString(level),
                message,
            },
        );
    }

    fn logf(
        level: LogLevel,
        comptime fmt: []const u8,
        args: anytype,
    ) void {
        const timestamp = std.time.timestamp();

        std.debug.print(
            "[{d}] [{s}] ",
            .{
                timestamp,
                levelString(level),
            },
        );

        std.debug.print(
            fmt,
            args,
        );

        std.debug.print(
            "\n",
            .{},
        );
    }

    fn levelString(
        level: LogLevel,
    ) []const u8 {
        return switch (level) {
            .debug => "DEBUG",
            .info => "INFO",
            .warn => "WARN",
            .err => "ERROR",
        };
    }
};

// Convenience functions

pub fn debug(
    message: []const u8,
) void {
    Logger.debug(message);
}

pub fn info(
    message: []const u8,
) void {
    Logger.info(message);
}

pub fn warn(
    message: []const u8,
) void {
    Logger.warn(message);
}

pub fn err(
    message: []const u8,
) void {
    Logger.err(message);
}

pub fn debugf(
    comptime fmt: []const u8,
    args: anytype,
) void {
    Logger.debugf(fmt, args);
}

pub fn infof(
    comptime fmt: []const u8,
    args: anytype,
) void {
    Logger.infof(fmt, args);
}

pub fn warnf(
    comptime fmt: []const u8,
    args: anytype,
) void {
    Logger.warnf(fmt, args);
}

pub fn errf(
    comptime fmt: []const u8,
    args: anytype,
) void {
    Logger.errf(fmt, args);
}
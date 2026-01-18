const std = @import("std");

const ShelfData = packed struct(u8) {
    roll: u4,
    local_count: u4,
};

pub fn parseShelf(symbol: u8) !bool {
    return switch (symbol) {
        '@' => true,
        '.' => false,
        else => error.InvalidShelfSymbol,
    };
}

pub fn processLine(in: []const u8, out: []ShelfData) !void {
    if (in.len != out.len) return error.LenMismatch;

    for (in, out) |symbol, *shelf| {
        shelf.*.roll = @intFromBool(try parseShelf(symbol));
    }
    var i: usize = 1;
    while (i < out.len - 1) : (i += 1) {
        out[i].local_count = out[i - 1].roll + out[i].roll + out[i + 1].roll;
    }

    if (out.len > 1) {
        out[0].local_count = out[0].roll + out[1].roll;
        out[out.len - 1].local_count = out[out.len - 2].roll + out[out.len - 1].roll;
    } else if (out.len == 1) {
        out[0].local_count = out[0].roll;
    }
}

pub fn RotatingIndex(comptime M: usize) type {
    return struct {
        offset: usize,

        const Self = @This();
        const Zero: Self = .{ .offset = 0 };

        pub fn at(self: *Self, i: usize) usize {
            return (i + self.offset) % M;
        }

        pub fn advance(self: *Self, n: usize) void {
            self.offset = (self.offset + n) % M;
        }

        pub fn increment(self: *Self) void {
            self.advance(1);
        }
    };
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var reader_buf: [1024]u8 = undefined;
    var freader = file.reader(&reader_buf);
    const reader = &freader.interface;

    var process_buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&process_buf);
    const allocator = fba.allocator();

    const line_len = (try reader.peekDelimiterExclusive('\n')).len;

    const line_buf: []ShelfData = try allocator.alloc(ShelfData, 3 * line_len);
    defer allocator.free(line_buf);
    var lines: [3][]ShelfData = undefined;
    {
        var head: usize = 0;
        for (&lines) |*line| {
            line.* = line_buf[head .. head + line_len];
            head += line_len;
        }
    }

    const input_buf: []u8 = try reader.readAlloc(allocator, line_len);
    defer allocator.free(input_buf);
    reader.toss(1);
    try processLine(input_buf, lines[0]);
    try reader.readSliceAll(input_buf);
    reader.toss(1);
    try processLine(input_buf, lines[1]);

    var accessible_count: u32 = 0;

    for (lines[0], lines[1]) |level, below| {
        if (level.roll != 0 and level.local_count + below.local_count <= 4) {
            accessible_count += 1;
        }
    }

    var idx: RotatingIndex(3) = .Zero;
    while (reader.readSliceAll(input_buf)) : (idx.increment()) {
        reader.toss(1);
        try processLine(input_buf, lines[idx.at(2)]);

        for (lines[idx.at(0)], lines[idx.at(1)], lines[idx.at(2)]) |above, level, below| {
            if (level.roll != 0 and above.local_count + level.local_count + below.local_count <= 4) {
                accessible_count += 1;
            }
        }
    } else |err| switch (err) {
        std.io.Reader.Error.EndOfStream => {},
        else => return err,
    }

    for (lines[idx.at(0)], lines[idx.at(1)]) |above, level| {
        if (level.roll != 0 and above.local_count + level.local_count <= 4) {
            accessible_count += 1;
        }
    }

    std.debug.print("{d}\n", .{accessible_count});
}

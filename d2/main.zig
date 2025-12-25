const std = @import("std");

pub fn splitByHyphen(range: []const u8) !struct { []const u8, []const u8 } {
    const dash_index: usize = std.mem.indexOfScalar(u8, range, '-') orelse return error.MissingHyphen;
    return .{ range[0..dash_index], range[dash_index + 1 ..] };
}

pub fn splitNum(allocator: std.mem.Allocator, n: u64, num_str: []const u8) ![]const u64 {
    std.debug.assert(num_str.len % n == 0);
    const chunk_size = num_str.len / n;
    var parts = try std.ArrayList(u64).initCapacity(allocator, n);
    for (0..n) |i| {
        const chunk = num_str[i * chunk_size .. (i + 1) * chunk_size];
        parts.appendAssumeCapacity(try std.fmt.parseInt(u64, chunk, 10));
    }
    return parts.toOwnedSlice(allocator);
}

pub fn lowestBlock(allocator: std.mem.Allocator, n: u64, num_str: []const u8) !u64 {
    if (num_str.len % n == 0) {
        const split: []const u64 = try splitNum(allocator, n, num_str);
        defer allocator.free(split);
        const first = split[0];
        for (split[1..]) |num| {
            if (num < first) return first;
            if (num > first) return first + 1;
        }
        return first;
    } else {
        const pow = num_str.len / n;
        return std.math.powi(u64, 10, pow);
    }
}

pub fn highestBlock(allocator: std.mem.Allocator, n: u64, num_str: []const u8) !u64 {
    if (num_str.len % n == 0) {
        const split: []const u64 = try splitNum(allocator, n, num_str);
        defer allocator.free(split);
        const first = split[0];
        for (split[1..]) |num| {
            if (num > first) return first;
            if (num < first) return first - 1;
        }
        return first;
    } else {
        const pow = num_str.len / n;
        return (try std.math.powi(u64, 10, pow)) - 1;
    }
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{});

    var buffer: [1024]u8 = undefined;
    var freader = file.reader(&buffer);
    const reader = &freader.interface;

    var content: [1024]u8 = undefined;
    const size = try reader.readSliceShort(&content);
    if (!freader.atEnd()) return error.FileTooLarge;

    file.close();

    var fixed_buf: [16384]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&fixed_buf);
    const allocator = fba.allocator();

    const trimmed = std.mem.trimEnd(u8, content[0..size], "\n");

    var sum: u64 = 0;

    var it = std.mem.splitScalar(u8, trimmed, ',');
    while (it.next()) |range_str| {
        defer fba.reset();
        const start_str, const end_str = try splitByHyphen(range_str);

        var found = std.AutoArrayHashMap(u64, void).init(allocator);
        defer found.deinit();
        for (2..@max(start_str.len, end_str.len) + 1) |n| {
            const lowest: u64 = try lowestBlock(allocator, n, start_str);
            const highest: u64 = try highestBlock(allocator, n, end_str);

            if (lowest > highest) continue;

            var base: u64 = std.math.log10_int(lowest);
            for (lowest..highest + 1) |num| {
                if (num >= try std.math.powi(u64, 10, base)) base += 1;
                var entry: u64 = 0;
                for (0..n) |i| {
                    entry += num * try std.math.powi(u64, 10, i * base);
                }
                try found.put(entry, {});
            }
        }
        for (found.keys()) |num| {
            sum += num;
        }
    }

    std.debug.print("sum: {d}\n", .{sum});
}

const std = @import("std");
// Get the ends of the ranges as strings
// Clamp if odd digit count
// Split the strings in half and parse as ints

pub fn splitByHyphen(range: []const u8) !struct { []const u8, []const u8 } {
    const dash_index: usize = std.mem.indexOfScalar(u8, range, '-') orelse return error.NoHyphen;
    return .{ range[0..dash_index], range[dash_index + 1 ..] };
}

const LeftRight = struct { left: u64, right: u64 };
const StartEnd = struct { start: LeftRight, end: LeftRight };

pub fn pow10(exponent: u64) u64 {
    return std.math.powi(u64, 10, exponent) catch unreachable;
}

pub fn sumBetween(a: u64, b: u64) u64 {
    return (b + a) * (b - a + 1) / 2;
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

    const trimmed = std.mem.trimEnd(u8, content[0..size], "\n");

    var sum: u64 = 0;

    var it = std.mem.splitScalar(u8, trimmed, ',');
    while (it.next()) |range_str| {
        const start_str, const end_str = try splitByHyphen(range_str);

        const start_width: u64 = @intCast(start_str.len / 2);
        const end_width: u64 = @intCast(end_str.len / 2);

        const start: LeftRight = if (start_str.len % 2 == 0) .{
            .left = try std.fmt.parseInt(u64, start_str[0 .. start_str.len / 2], 10),
            .right = try std.fmt.parseInt(u64, start_str[start_str.len / 2 ..], 10),
        } else blk: {
            const smallest = try std.math.powi(u64, 10, start_width);
            break :blk .{ .left = smallest, .right = smallest };
        };
        const end: LeftRight = if (end_str.len % 2 == 0) .{
            .left = try std.fmt.parseInt(u64, end_str[0 .. end_str.len / 2], 10),
            .right = try std.fmt.parseInt(u64, end_str[end_str.len / 2 ..], 10),
        } else blk: {
            const largest = try std.math.powi(u64, 10, end_width) - 1;
            break :blk .{ .left = largest, .right = largest };
        };

        const first: u64 = if (start.left >= start.right) start.left else start.left + 1;
        const last: u64 = if (end.left <= end.right) end.left else end.left - 1;

        if (last < first) continue;

        const start_pow = std.math.log10_int(start.left);
        const end_pow = std.math.log10_int(end.left);

        const start_ten: u64 = pow10(start_pow + 1);
        if (end_pow == start_pow) {
            const gauss = sumBetween(first, last);
            sum += (start_ten + 1) * gauss;
            continue;
        }

        const start_gauss = sumBetween(first, start_ten - 1);
        const end_gauss = sumBetween(start_ten, last);
        sum += (start_ten + 1) * start_gauss + (start_ten * 10 + 1) * end_gauss;
        if (end_pow - start_pow == 1) continue;

        sum += 55 * (pow10(3 * end_pow) - pow10(3 * start_pow)) / 111;
        sum -= 5 * (pow10(2 * end_pow) - pow10(2 * start_pow)) / 11;
        sum += sumBetween(start_ten, pow10(end_pow));
    }

    std.debug.print("sum: {d}\n", .{sum});
}

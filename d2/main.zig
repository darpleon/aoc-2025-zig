const std = @import("std");

pub fn parseRange(range: []const u8) !struct { u32, u32 } {
    const dash_index: usize = std.mem.indexOfScalar(u8, range, '-') orelse return error.NoHyphen;
    const start_str = range[0..dash_index];
    const end_str = range[dash_index + 1 ..];
    return .{ try std.fmt.parseInt(u32, start_str, 10), try std.fmt.parseInt(u32, end_str, 10) };
}

pub fn main() !void {
    const file = try std.fs.cwd().openFile("example", .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var freader = file.reader(&buffer);
    const reader = &freader.interface;

    var content: [1024]u8 = undefined;
    const size = try reader.readSliceShort(&content);
    if (!freader.atEnd()) return error.FileTooLarge;
    const trimmed = std.mem.trimEnd(u8, content[0..size], "\n");

    var it = std.mem.splitScalar(u8, trimmed, ',');
    while (it.next()) |range_str| {
        const start: u32, const end: u32 = try parseRange(range_str);
        std.debug.print("start: {d} -- end: {d}\n", .{ start, end });
    }
}

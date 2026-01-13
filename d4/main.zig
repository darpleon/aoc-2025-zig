const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("example", .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var freader = file.reader(&buffer);
    const reader = &freader.interface;

    var fixed_buf: [1024]u8 = undefined;
    var fba = std.heap.FixedBufferAllocator.init(&fixed_buf);
    const allocator = fba.allocator();

    const line_len = (try reader.peekDelimiterExclusive('\n')).len;
    const line_buf: []u8 = try allocator.alloc(u8, 3 * line_len);
    var lines: [3][]u8 = undefined;
    for (&lines, 0..3) |*line, i| {
        line.* = line_buf[i * line_len .. (i + 1) * line_len];
    }
    try reader.readSliceAll(lines[0]);
    reader.toss(1);
    try reader.readSliceAll(lines[1]);
    reader.toss(1);

    while (reader.readSliceAll(lines[2])) {
        reader.toss(1);
        std.debug.print("---\n{s}\n{s}\n{s}\n---\n", .{lines[0], lines[1], lines[2]});
        // ...
        lines[0] = lines[1];
        lines[1] = lines[2];
        lines[2] = lines[0];
    } else |err| switch (err) {
        std.io.Reader.Error.EndOfStream => {},
        else => return err,
    }
}

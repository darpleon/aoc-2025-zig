const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buffer: [16384]u8 = undefined;
    var freader = file.reader(&buffer);
    const reader = &freader.interface;

    var line_no: usize = 0;
    var zero_count: u16 = 0;

    var pos: u8 = 50;

    while (reader.takeDelimiterExclusive('\n')) |line| {
        defer reader.toss(1);
        line_no += 1;
        if (line.len > 0) {
            const direction = line[0];
            const distance_str = line[1..];

            const distance: u8 = @intCast((try std.fmt.parseInt(u16, distance_str, 10)) % 100);

            switch (direction) {
                'L' => pos = (pos + 100 - distance) % 100,
                'R' => pos = (pos + distance) % 100,
                else => unreachable,
            }

            if (pos == 0) {
                zero_count += 1;
            }
        }
    } else |err| switch (err) {
        error.EndOfStream => {},
        else => return err,
    }

    std.debug.print("{d}\n", .{zero_count});
}

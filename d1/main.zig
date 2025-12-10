const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buffer: [16384]u8 = undefined;
    var freader = file.reader(&buffer);
    const reader = &freader.interface;

    var landed_zero_count: u32 = 0;
    var passed_zero_count: u32 = 0;

    var pos: u32 = 50;

    var line_no: usize = 0;
    while (reader.takeDelimiter('\n')) |maybe_line| {
        const line = maybe_line orelse break;

        line_no += 1;
        if (line.len < 2) {
            unreachable;
        }
        const direction = line[0];
        const distance_str = line[1..];

        const distance: u32 = try std.fmt.parseInt(u32, distance_str, 10);

        passed_zero_count += distance / 100;
        const remainder: u32 = distance % 100;

        switch (direction) {
            'L' => {
                passed_zero_count += if (remainder >= pos and pos != 0) 1 else 0;
                pos = (pos + 100 - remainder) % 100;
            },
            'R' => {
                passed_zero_count += if (remainder >= 100 - pos) 1 else 0;
                pos = (pos + remainder) % 100;
            },
            else => unreachable,
        }

        if (pos == 0) {
            landed_zero_count += 1;
        }
    } else |err| return err;

    std.debug.print("Landed on zero {d} times\n", .{landed_zero_count});
    std.debug.print("Passed zero {d} times\n", .{passed_zero_count});
}

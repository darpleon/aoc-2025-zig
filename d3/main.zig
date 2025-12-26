const std = @import("std");

pub fn main() !void {
    const file = try std.fs.cwd().openFile("input", .{});
    defer file.close();

    var buffer: [1024]u8 = undefined;
    var freader = file.reader(&buffer);
    const reader = &freader.interface;

    var sum: u64 = 0;
    while (reader.takeDelimiter('\n')) |maybe_line| {
        const line = maybe_line orelse break;
        if (line.len < 2) return error.LineTooShort;

        var left_candidate: u64 = 0;
        var right_candidate: u64 = 0;
        for (line) |char| {
            const digit: u64 = char - '0';

            if (left_candidate < right_candidate) {
                left_candidate = right_candidate;
                right_candidate = 0;
            }

            if (digit > right_candidate) {
                right_candidate = digit;
            }
        }
        sum += left_candidate * 10 + right_candidate;
    } else |err| return err;
    std.debug.print("sum: {d}\n", .{sum});
}

const std = @import("std");

const digit_count = 12;

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

        var digits: [digit_count]u64 = .{0} ** digit_count;
        for (line) |char| {
            const new_digit: u64 = char - '0';

            for (0..digit_count - 1) |i| {
                if (digits[i] < digits[i + 1]) {
                    digits[i] = digits[i + 1];
                    digits[i + 1] = 0;
                }
            }
            
            if (new_digit > digits[digit_count - 1]) {
                digits[digit_count - 1] = new_digit;
            }
        }
        var pow10: u64 = 1;
        for (0..digit_count) |i| {
            sum += pow10 * digits[digit_count - i - 1];
            pow10 *= 10;
        }
    } else |err| return err;
    std.debug.print("sum: {d}\n", .{sum});
}

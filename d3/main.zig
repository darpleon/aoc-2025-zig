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
        var head: usize = 0;
        for (line, 0..) |char, i| {
            const new_digit: u64 = char - '0';

            while (head > 0 and digit_count - head < line.len - i and
                new_digit > digits[head - 1]) : (head -= 1)
            {}

            if (head < digit_count) {
                digits[head] = new_digit;
                head += 1;
            }
        }
        var joltage: u64 = 0;
        for (digits) |digit| {
            joltage = joltage * 10 + digit;
        }
        sum += joltage;
    } else |err| return err;
    std.debug.print("sum: {d}\n", .{sum});
}

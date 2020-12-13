const std = @import("std");
const mecha = @import("mecha");

const int = mecha.int(usize, 10);

pub fn main() anyerror!void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    if (std.os.argv.len != 2) return error.BadArgs;

    const sum = (int(std.mem.spanZ(std.os.argv[1])) orelse return error.NotANumber).value;

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();

    var prices = std.ArrayList(usize).init(&gpa.allocator);
    defer prices.deinit();

    var buf: [80]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        try prices.append((int(line) orelse return error.NotANumber).value);
    }

    const answer = blk: for (prices.items) |first, i| {
        for (prices.items) |second, j| {
            if (i == j) continue;
            if (first + second > sum) continue;

            const wanted = sum - first - second;
            for (prices.items) |val, k| {
                if (k == i or k == j) continue;

                if (val == wanted) {
                    break :blk first * second * val;
                }
            }
        }
    } else return error.AnswerNotFound;

    try stdout.print("{}\n", .{answer});
}

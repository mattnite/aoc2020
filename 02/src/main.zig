const std = @import("std");
const mecha = @import("mecha");

const Entry = struct {
    min: usize,
    max: usize,
    character: u21,
    password: []const u8,

    const Self = @This();

    fn isValid(self: Self) bool {
        const first = self.character == self.password[self.min - 1];
        const second = self.character == self.password[self.max - 1];

        return first or second and !(first and second);
    }
};

// TODO: figure out parser
const entry = mecha.as(Entry, mecha.toStruct(Entry), mecha.combine(.{
    mecha.int(usize, 10),
    mecha.char('-'),
    mecha.int(usize, 10),
    mecha.char(' '),
    mecha.alpha,
    mecha.string(": "),
    mecha.any,
}));

pub fn main() anyerror!void {
    const stdin = std.io.getStdIn().reader();
    const stdout = std.io.getStdOut().writer();

    var count: usize = 0;
    var buf: [80]u8 = undefined;
    while (try stdin.readUntilDelimiterOrEof(&buf, '\n')) |line| {
        const pass_entry = (entry(line) orelse return error.BadPassEntry).value;
        if (pass_entry.isValid()) {
            count += 1;
        }
    }

    try stdout.print("{}\n", .{count});
}

const std = @import("std");
const Io = std.Io;

const Rt = @import("runtime.zig");

pub fn main(init: std.process.Init) !void {
    const io = init.io;
    const alloc = init.gpa;

    var args = init.minimal.args.iterate();
    _ = args.next();

    var source: []u8 = undefined;

    if (args.next()) |file_path| {
        source = try std.Io.Dir.cwd().readFileAlloc(
            io,
            file_path,
            alloc,
            .unlimited,
        );
    } else {
        std.debug.print("Missing brainfuck file!!!\n", .{});
        std.process.exit(1);
    }

    defer alloc.free(source);

    const height = std.mem.count(u8, source, "\n");
    const width = maxWidth(source);

    var lines = std.mem.tokenizeAny(u8, source, "\n");

    const grid: []u8 = try alloc.alloc(u8, height * width);
    defer alloc.free(grid);

    for (0..height) |y| {
        const line = lines.next().?;
        for (0..width) |x| {
            if (line.len > x) {
                grid[x + y * width] = line[x];
            } else {
                grid[x + y * width] = ' ';
            }
        }
    }

    var rt = Rt{ .grid = grid, .width = width, .height = height };
    defer rt.deinit(alloc);

    while (try rt.step(alloc, io)) {}
}

fn maxWidth(grid: []const u8) usize {
    var max: usize = 0;
    var lines = std.mem.tokenizeAny(u8, grid, "\n");

    while (lines.next()) |l| {
        if (l.len > max) max = l.len;
    }

    return max;
}

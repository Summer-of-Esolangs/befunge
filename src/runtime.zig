//! Befunge grid interpreting runtime babyyyy

const std = @import("std");

const PcDir = enum {
    up,
    down,
    left,
    right,
};

const Pc = struct {
    x: usize = 0,
    y: usize = 0,
};

grid: []u8,
width: usize,
height: usize,

pc: Pc = .{},
dir: PcDir = .right,

stack: std.ArrayList(u8) = .empty,

const Rt = @This();

pub fn updatePc(rt: *Rt, dir: PcDir) void {
    switch (dir) {
        .up => if (rt.pc.y == 0) {
            rt.pc.y = rt.height - 1;
        } else {
            rt.pc.y -= 1;
        },

        .down => if (rt.pc.y == rt.height - 1) {
            rt.pc.y = 0;
        } else {
            rt.pc.y += 1;
        },

        .left => if (rt.pc.x == 0) {
            rt.pc.x = rt.width - 1;
        } else {
            rt.pc.x -= 1;
        },

        .right => if (rt.pc.x == rt.width - 1) {
            rt.pc.x = 0;
        } else {
            rt.pc.x += 1;
        },
    }
}

pub fn deinit(rt: *Rt, alloc: std.mem.Allocator) void {
    rt.stack.deinit(alloc);
}

pub fn push(rt: *Rt, alloc: std.mem.Allocator, val: u8) !void {
    try rt.stack.append(alloc, val);
}

pub fn pop(rt: *Rt) u8 {
    return rt.stack.pop() orelse 0;
}

pub fn step(rt: *Rt, alloc: std.mem.Allocator, io: std.Io) !bool {
    const stdin = std.Io.File.stdin();
    var buffer: [1]u8 = undefined;
    var reader = stdin.reader(io, &buffer);

    const cell = rt.grid[rt.pc.y * rt.width + rt.pc.x];
    switch (cell) {
        '+' => {
            const a = rt.pop();
            const b = rt.pop();
            try rt.push(alloc, a + b);
        },

        '-' => {
            const a = rt.pop();
            const b = rt.pop();
            try rt.push(alloc, b - a);
        },

        '*' => {
            const a = rt.pop();
            const b = rt.pop();
            try rt.push(alloc, a * b);
        },

        '/' => {
            const a = rt.pop();
            const b = rt.pop();
            try rt.push(alloc, b / a);
        },

        '%' => {
            const a = rt.pop();
            const b = rt.pop();
            try rt.push(alloc, b % a);
        },

        '!' => {
            const a = rt.pop();
            if (a == 0) {
                try rt.push(alloc, 1);
            } else {
                try rt.push(alloc, 0);
            }
        },

        '`' => {
            const a = rt.pop();
            const b = rt.pop();

            const res: u8 = if (b > a) 1 else 0;

            try rt.push(alloc, res);
        },

        '^' => rt.dir = .up,
        'v' => rt.dir = .down,
        '>' => rt.dir = .right,
        '<' => rt.dir = .left,

        '?' => {
            var source: std.Random.IoSource = .{ .io = io };
            const rand = source.interface();

            rt.dir = rand.enumValue(PcDir);
        },

        '_' => {
            const a = rt.pop();

            if (a == 0) {
                rt.dir = .right;
            } else {
                rt.dir = .left;
            }
        },

        '|' => {
            const a = rt.pop();

            if (a == 0) {
                rt.dir = .down;
            } else {
                rt.dir = .up;
            }
        },

        '"' => {
            rt.updatePc(rt.dir);
            while (rt.grid[rt.pc.y * rt.width + rt.pc.x] != '"') {
                const val = rt.grid[rt.pc.y * rt.width + rt.pc.x];
                try rt.push(alloc, val);
                rt.updatePc(rt.dir);
            }
        },

        ':' => {
            const a = rt.pop();
            try rt.push(alloc, a);
            try rt.push(alloc, a);
        },

        '\\' => {
            const a = rt.pop();
            const b = rt.pop();

            try rt.push(alloc, a);
            try rt.push(alloc, b);
        },

        '$' => _ = rt.pop(),

        '.' => {
            const a = rt.pop();
            std.debug.print("{}", .{a});
        },

        ',' => {
            const a = rt.pop();
            std.debug.print("{c}", .{a});
        },

        '#' => rt.updatePc(rt.dir),

        'g' => {
            const y = rt.pop();
            const x = rt.pop();

            const val = rt.grid[y * rt.width + x];
            try rt.push(alloc, val);
        },

        'p' => {
            const y = rt.pop();
            const x = rt.pop();
            const v = rt.pop();

            rt.grid[y * rt.width + x] = v;
        },

        '&' => {
            const byte = try reader.interface.takeByte();
            try rt.push(alloc, byte - '0');
        },
        '~' => {
            const byte = try reader.interface.takeByte();
            try rt.push(alloc, byte);
        },

        '@' => return false,

        else => {},
    }

    rt.updatePc(rt.dir);

    if (rt.pc.x >= rt.width or rt.pc.y >= rt.height) {
        std.debug.print("Error!!!!! PC Fell :(\n", .{});
        return false;
    }

    return true;
}

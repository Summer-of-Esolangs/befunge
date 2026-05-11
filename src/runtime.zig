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

    pub fn update(pc: *Pc, dir: PcDir) void {
        switch (dir) {
            .up => pc.y -= 1,
            .down => pc.y += 1,
            .left => pc.x -= 1,
            .right => pc.x += 1,
        }
    }
};

grid: []u8,
width: usize,
height: usize,

pc: Pc = .{},
dir: PcDir = .right,

stack: std.ArrayList(u8) = .empty,

const Rt = @This();

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
    _ = io;

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

        '"' => {
            rt.pc.update(rt.dir);
            while (rt.grid[rt.pc.y * rt.width + rt.pc.x] != '"') {
                const val = rt.grid[rt.pc.y * rt.width + rt.pc.x];
                try rt.push(alloc, val);
                rt.pc.update(rt.dir);
            }
        },

        '^' => rt.dir = .up,
        'v' => rt.dir = .down,
        '>' => rt.dir = .right,
        '<' => rt.dir = .left,

        '.' => {
            const a = rt.pop();
            std.debug.print("{}", .{a});
        },

        ',' => {
            const a = rt.pop();
            std.debug.print("{c}", .{a});
        },

        ':' => {
            const a = rt.pop();
            try rt.push(alloc, a);
            try rt.push(alloc, a);
        },

        '_' => {
            const a = rt.pop();

            if (a == 0) {
                rt.dir = .right;
            } else {
                rt.dir = .left;
            }
        },

        '@' => return false,

        else => {},
    }

    rt.pc.update(rt.dir);

    if (rt.pc.x >= rt.width or rt.pc.y >= rt.height) {
        std.debug.print("Error!!!!! PC Fell :(\n", .{});
        return false;
    }

    return true;
}

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
            .up => pc.y += 1,
            .down => pc.y -= 1,
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

pub fn step(rt: *Rt, alloc: std.mem.Allocator, io: std.Io) !bool {
    _ = alloc;
    _ = io;

    const cell = rt.grid[rt.pc.y * rt.width + rt.pc.x];
    switch (cell) {
        else => {},
    }

    rt.pc.update(rt.dir);

    if (rt.pc.x >= rt.width or rt.pc.y >= rt.height) {
        std.debug.print("Error!!!!! PC Fell :(\n", .{});
        return false;
    }

    return true;
}

const Maze = @import("maze.zig").Maze;
const heap = @import("std").heap;
const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));

pub const ObjectType = enum {
    Wall,
    Path,
    Finish,
};

pub const Object = struct {
    rect: rl.Rectangle,
    state: ObjectType,

    const Self = @This();

    pub fn init(rect: rl.Rectangle, state: ObjectType) Self {
        return Self{
            .rect = rect,
            .state = state,
        };
    }
};

pub const GameState = struct {
    win_width: f32,
    win_height: f32,
    objects: std.ArrayList(Object),
    allocator: std.mem.Allocator,
    sprites_size: f32 = 40,

    const Self = @This();

    pub fn init(w: f32, h: f32, alloc: std.mem.Allocator) Self {
        return Self{
            .win_width = w,
            .win_height = h,
            .objects = std.ArrayList(Object).init(alloc),
            .allocator = alloc,
        };
    }

    pub fn updateObject(self: *Self, obj: Object, idx: usize) void {
        self.objects.items[idx] = obj;
    }

    pub fn addObject(self: *Self, obj: Object) void {
        self.objects.append(obj) catch std.debug.print("Couldn't append\n", .{});
    }

    pub fn insideWindow(self: *Self, pos: rl.Rectangle) bool {
        return 0 <= pos.x and
            pos.x <= self.win_width - pos.width and
            0 <= pos.y and
            pos.y <= self.win_height - pos.height;
    }

    pub fn collides(self: *Self, pos: rl.Rectangle) bool {
        for (self.objects.items) |obj| {
            if (obj.state == .Wall and rl.CheckCollisionRecs(pos, obj.rect)) {
                return true;
            }
        }
        return false;
    }

    pub fn drawObjects(self: *Self) void {
        for (self.objects.items) |obj| {
            switch (obj.state) {
                .Wall => rl.DrawRectangleRec(obj.rect, rl.BLUE),
                .Path => rl.DrawRectangleRec(obj.rect, rl.GRAY),
                .Finish => rl.DrawRectangleRec(obj.rect, rl.GREEN),
            }
        }
    }
};

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
    wall_sprite: rl.Texture2D,
    finish_sprite: rl.Texture2D,
    path_sprite: rl.Texture2D,
    finish_obj: Object = undefined,
    sprites_size: f32 = 40,

    const Self = @This();

    pub fn init(w: f32, h: f32, alloc: std.mem.Allocator) Self {
        const wall_sprite = rl.LoadTexture("./assets/wall.png");
        const finish_sprite = rl.LoadTexture("./assets/finish.png");
        const path_sprite = rl.LoadTexture("./assets/path.png");

        return Self{
            .win_width = w,
            .win_height = h,
            .objects = std.ArrayList(Object).init(alloc),
            .allocator = alloc,
            .wall_sprite = wall_sprite,
            .finish_sprite = finish_sprite,
            .path_sprite = path_sprite,
        };
    }

    pub fn reachedFinish(self: *Self, pos: rl.Rectangle) bool {
        return rl.CheckCollisionRecs(pos, self.finish_obj.rect);
    }

    pub fn updateFinishObj(self: *Self, obj: Object) void {
        self.finish_obj = obj;
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
            const sprite = switch (obj.state) {
                .Wall => self.wall_sprite,
                .Path => self.path_sprite,
                .Finish => self.finish_sprite,
            };

            if (rl.IsTextureReady(sprite)) {
                rl.DrawTexture(sprite, @intFromFloat(obj.rect.x), @intFromFloat(obj.rect.y), rl.RAYWHITE);
            }
        }
    }
};

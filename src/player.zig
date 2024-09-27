const rl = @cImport(@cInclude("raylib.h"));
const std = @import("std");

// Player will have it's sprite width and height be the same
pub const Player = struct {
    rect: rl.Rectangle,
    speed: f32,
    sprite: rl.Texture2D,
    score: u32 = 0,

    const Self = @This();

    pub fn init(rect: rl.Rectangle, speed: f32) Self {
        const sprite: rl.Texture2D = rl.LoadTexture("./assets/player.png");
        return Self{
            .rect = rect,
            .speed = speed,
            .sprite = sprite,
        };
    }

    pub fn getPos(self: *const Self) rl.Vector2 {
        return rl.Vector2{
            .x = self.rect.x,
            .y = self.rect.y,
        };
    }

    pub fn increaseScore(self: *Self) void {
        self.score += 1;
    }

    pub fn dbg_player_pos(self: *Self) void {
        std.debug.print("Player pos: {} {} {} {}\n", .{self.rect.x, self.rect.y, self.rect.x + self.rect.width, self.rect.y + self.rect.height});
    }

    pub fn setPos(self: *Self, pos: rl.Vector2) void {
        self.rect.x = pos.x;
        self.rect.y = pos.y;
    }

    pub fn draw(self: *const Self) void {
        rl.DrawRectangleRec(self.rect, rl.RAYWHITE);
        rl.DrawTexture(self.sprite, @intFromFloat(self.rect.x), @intFromFloat(self.rect.y), rl.RAYWHITE);
    }

    pub fn tryMove(self: *const Self, dist: rl.Vector2) rl.Rectangle {
        return rl.Rectangle{
            .x = self.rect.x + dist.x,
            .y = self.rect.y + dist.y,
            .width = self.rect.width,
            .height = self.rect.width,
        };
    }
};

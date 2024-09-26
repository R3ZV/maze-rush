const rl = @cImport(@cInclude("raylib.h"));

// Player will have it's sprite width and height be the same
pub const Player = struct {
    rect: rl.Rectangle,
    speed: f32,

    const Self = @This();

    pub fn init(rect: rl.Rectangle, speed: f32) Self {
        return Self{
            .rect = rect,
            .speed = speed,
        };
    }

    pub fn getPos(self: *const Self) rl.Vector2 {
        return rl.Vector2{
            .x = self.rect.x,
            .y = self.rect.y,
        };
    }

    pub fn setPos(self: *Self, pos: rl.Vector2) void {
        self.rect.x = pos.x;
        self.rect.y = pos.y;
    }

    pub fn draw(self: *const Self) void {
        rl.DrawRectangleRec(self.rect, rl.RAYWHITE);
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

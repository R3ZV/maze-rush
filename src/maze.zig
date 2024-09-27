const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));

pub fn Maze(w: u32, h: u32, sprite_w: u32) type {
    return struct {
        const Self = @This();
        width: u32 = w,
        height: u32 = h,
        sprite_width: u32 = sprite_w,
        grid: [h][w]u8 = std.mem.zeroes([h][w]u8),

        pub fn init() Self {
            return Self{};
        }

        pub fn projectOnWindow(self: *const Self, i: f32, j: f32, sprite_size: f32) rl.Rectangle {
            _ = self;
            return rl.Rectangle{
                .x = i * sprite_size,
                .y = j * sprite_size,
                .width = sprite_size,
                .height = sprite_size,
            };
        }

        pub fn isExit(self: *const Self, pos: [2]u32) bool {
            return pos[0] == 0 or
                pos[0] == self.width - 1 or
                pos[1] == 0 or
                pos[1] == self.height - 1;
        }

        fn getSeed() u64 {
            var buff: [8]u8 = undefined;
            std.posix.getrandom(&buff) catch return 0;
            return std.mem.bytesToValue(u64, &buff);
        }

        /// This maze generation will make use of a dfs type of algorithm
        /// that goes as follows:
        ///
        /// 1. Pick a starting node which we will call "curr_node"
        /// 2. Generate a random direction (N, E, S, W), if from the
        /// "curr_node" we can move in that direction, update "curr_node" to
        /// the node we get from going in the said direction.
        /// 3. Repeat step 2 until we reach 1 exit.
        ///
        /// At the end it will return the starting node position to be used
        /// by the player.
        pub fn genMazeDfs(self: *Self) rl.Rectangle {
            self.grid = std.mem.zeroes([h][w]u8);
            var rng = std.Random.DefaultPrng.init(getSeed());
            var rand_gen = rng.random();

            // curr_node[0] = x;
            // curr_node[1] = y;
            var curr_node: [2]u32 = .{
                rand_gen.intRangeAtMost(u32, self.width / 3, self.width / 2),
                rand_gen.intRangeAtMost(u32, self.height / 3, self.height / 2),
            };
            const starting_pos = self.projectOnWindow(@floatFromInt(curr_node[0]), @floatFromInt(curr_node[1]), @floatFromInt(self.sprite_width));

            const di: [4]i8 = .{ -1, 1, 0, 0 };
            const dj: [4]i8 = .{ 0, 0, -1, 1 };

            // TODO: use a stack / queue or make it reccursive
            while (!self.isExit(curr_node)) {
                self.grid[curr_node[1]][curr_node[0]] = 1;
                const dir: usize = rand_gen.intRangeAtMost(usize, 0, 3);

                curr_node[0] = @intCast(@as(i8, @intCast(curr_node[0])) + di[dir]);
                curr_node[1] = @intCast(@as(i8, @intCast(curr_node[1])) + dj[dir]);
            }

            if (self.isExit(curr_node)) {
                self.grid[curr_node[1]][curr_node[0]] = 1;
            }
            return starting_pos;
        }
    };
}

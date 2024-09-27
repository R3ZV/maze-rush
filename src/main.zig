const Maze = @import("maze.zig").Maze;
const Player = @import("player.zig").Player;
const GameState = @import("game_state.zig");

const std = @import("std");
const rl = @cImport(@cInclude("raylib.h"));

fn getSpritesSize(win_width: f32, win_height: f32) f32 {
    var sprites_size = 40;
    while (win_width % sprites_size != 0 and win_height % sprites_size != 0) {
        sprites_size += 0.1;
    }
    return sprites_size;
}

pub fn main() !void {
    const WIN_WIDTH: f32 = 800.0;
    const WIN_HEIGHT: f32 = 600.0;
    rl.InitWindow(WIN_WIDTH, WIN_HEIGHT, "Maze Rush");
    rl.InitAudioDevice();
    defer rl.CloseAudioDevice();

    rl.SetMasterVolume(50);

    rl.SetTargetFPS(60);

    const sprites_size: f32 = comptime getSpritesSize(WIN_WIDTH, WIN_HEIGHT);

    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    const alloc = gpa.allocator();
    var game_state: GameState.GameState = GameState.GameState.init(WIN_WIDTH, WIN_HEIGHT, alloc);

    const maze_width: u32 = comptime (WIN_WIDTH / sprites_size);
    const maze_height: u32 = comptime (WIN_HEIGHT / sprites_size);
    var maze = Maze(maze_width, maze_height, sprites_size).init();

    const player_rect = maze.genMazeDfs();

    for (0..maze.height) |j| {
        for (0..maze.width) |i| {
            var state = if (maze.grid[j][i] == 0) GameState.ObjectType.Wall else GameState.ObjectType.Path;
            if (maze.grid[j][i] == 1 and maze.isExit(.{@intCast(i), @intCast(j)})) {
                state = GameState.ObjectType.Finish;
            }
            const obj_rect: rl.Rectangle = maze.projectOnWindow(@floatFromInt(i), @floatFromInt(j), sprites_size);

            const obj = GameState.Object.init(obj_rect, state);
            if (state == GameState.ObjectType.Finish) game_state.updateFinishObj(obj);
            game_state.addObject(obj);
        }
    }

    const win_sound = rl.LoadSound("./assets/win.mp3");
    defer rl.UnloadSound(win_sound);
    var player = Player.init(player_rect, 5.0);
    var reached_finish = false;
    while (!rl.WindowShouldClose()) {
        var dist: rl.Vector2 = rl.Vector2{ .x = 0, .y = 0 };
        if (rl.IsKeyDown(rl.KEY_W)) {
            dist = rl.Vector2{ .x = 0, .y = -player.speed };
        } else if (rl.IsKeyDown(rl.KEY_A)) {
            dist = rl.Vector2{ .x = -player.speed, .y = 0 };
        } else if (rl.IsKeyDown(rl.KEY_S)) {
            dist = rl.Vector2{ .x = 0, .y = player.speed };
        } else if (rl.IsKeyDown(rl.KEY_D)) {
            dist = rl.Vector2{ .x = player.speed, .y = 0 };
        } else if (rl.IsKeyPressed(rl.KEY_R) or reached_finish) {
            reached_finish = false;
            const new_player_rect = maze.genMazeDfs();
            player.setPos(rl.Vector2{ .x = new_player_rect.x, .y = new_player_rect.y });
            for (0..maze.height) |j| {
                for (0..maze.width) |i| {
                    var state = if (maze.grid[j][i] == 0) GameState.ObjectType.Wall else GameState.ObjectType.Path;
                    if (maze.grid[j][i] == 1 and maze.isExit(.{@intCast(i), @intCast(j)})) {
                        state = GameState.ObjectType.Finish;
                    }
                    const obj_rect: rl.Rectangle = maze.projectOnWindow(@floatFromInt(i), @floatFromInt(j), sprites_size);

                    const obj = GameState.Object.init(obj_rect, state);
                    if (state == GameState.ObjectType.Finish) game_state.updateFinishObj(obj);
                    game_state.updateObject(obj, j * maze.width + i);
                }
            }
        }

        const new_player_pos: rl.Rectangle = player.tryMove(dist);

        if (game_state.insideWindow(new_player_pos) and
            !game_state.collides(new_player_pos))
        {
            player.setPos(rl.Vector2{ .x = new_player_pos.x, .y = new_player_pos.y });
        }

        // player.dbg_player_pos();
        if (game_state.reachedFinish(player.rect)) {
            reached_finish = true;
            player.increaseScore();
            rl.PlaySound(win_sound);
        }

        rl.BeginDrawing();

        game_state.drawObjects();
        player.draw();

        rl.ClearBackground(rl.BLACK);
        rl.EndDrawing();
    }
    defer rl.CloseWindow();
}

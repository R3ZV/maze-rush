mod maze;

use macroquad::prelude::*;

use maze::{GenTactic, Maze};

#[macroquad::main("BasicShapes")]
async fn main() {
    let win_width = 800.0;
    let win_height = 800.0;
    let block_size = 30.0;

    let mut maze_tactic = GenTactic::Bfs;
    let mut maze = Maze::new(
        (win_width / block_size) as usize,
        (win_height / block_size) as usize,
        block_size,
    );

    maze.gen(maze_tactic);

    loop {
        clear_background(WHITE);

        if is_key_pressed(KeyCode::R) {
            dbg!(&maze_tactic);
            maze.gen(maze_tactic);
        } else if is_key_pressed(KeyCode::Escape) {
            std::process::exit(1);
        } else if is_key_pressed(KeyCode::Key1) {
            maze_tactic = GenTactic::Dfs;
        } else if is_key_pressed(KeyCode::Key2) {
            maze_tactic = GenTactic::Bfs;
        } else if is_key_pressed(KeyCode::Key3) {
            maze_tactic = GenTactic::Kruskal;
        }

        maze.draw();

        next_frame().await
    }
}

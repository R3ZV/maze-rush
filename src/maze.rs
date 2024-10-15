use std::collections::VecDeque;

use macroquad::prelude::*;
use rand::gen_range;

pub struct Maze {
    width: usize,
    height: usize,
    grid: Vec<Vec<CellType>>,
    cell_size: f32,
}

#[derive(Clone, Copy, Debug)]
pub enum GenTactic {
    Dfs,
    Bfs,
    Kruskal,
}

#[derive(Clone)]
enum Direction {
    N,
    S,
    E,
    W,
    Unknown,
}

#[derive(Clone)]
enum WallType {
    // Is a cell that has another 4 'Wall' cells adjacent to it.
    PureWall,

    // Is a cell that has 3 'Wall' cell adjacent to it.
    OneWayWall,

    // Is a cell that has 2 'Wall' cells adjacent to it.
    TwoWayWall,

    // Is a cell that has 1 'Wall' cells adjacent to it.
    ThreeWayWall,

    // Is a cell that has 0 'Wall' cells adjacent to it.
    FourWayWall,

    Unknown,
}

#[derive(Clone)]
enum CellType {
    Wall(WallType, Direction),

    Path,
    Escape,
}

impl Maze {
    pub fn new(width: usize, height: usize, cell_size: f32) -> Self {
        let grid = vec![vec![CellType::Wall(WallType::Unknown, Direction::Unknown); width]; height];

        Self {
            width,
            height,
            grid,
            cell_size,
        }
    }

    /// Draws each cell to the screen, translating the grid to the propper
    /// screen size based on `block_size`.
    pub fn draw(&self) {
        for i in 0..self.height {
            for j in 0..self.width {
                let color = match self.grid[i][j] {
                    CellType::Wall(_, _) => RED,
                    CellType::Path => WHITE,
                    CellType::Escape => GREEN,
                };

                draw_rectangle(
                    j as f32 * self.cell_size,
                    i as f32 * self.cell_size,
                    self.cell_size,
                    self.cell_size,
                    color,
                );
            }
        }
    }

    /// Generates a random maze based on `GenTactic` maze generation
    /// algorith, it tries to start from a random cell in the middle.
    pub fn gen(&mut self, tactic: GenTactic) {
        let start_cell = (
            gen_range(self.width / 2 - 1, self.width / 2),
            gen_range(self.height / 2 - 1, self.height / 2),
        );

        match tactic {
            GenTactic::Dfs => self.dfs_maze(start_cell),
            GenTactic::Bfs => self.bfs_maze(start_cell),
            GenTactic::Kruskal => Self::kruskal_maze(),
        }

        // self.correct();
    }

    /// Transforms all the `Wall` cells into appropriate Wall
    /// based on how many neighbouring cells are also of type 'Wall'

    /// This function is used to help with sprite rendering
    /// to have more coherent srites that connect to each other.
    fn correct(&mut self) {
        todo!();
    }

    /// This generation tactic utilises a Dfs algorithm
    /// which picks a starting point from which it goes
    /// in random directions (e.g. N, S, E, W) until it reaches
    /// a 'escape' node (e.g. a node that is at the border of the grid).
    fn dfs_maze(&mut self, start_cell: (usize, usize)) {
        self.grid = vec![
            vec![CellType::Wall(WallType::Unknown, Direction::Unknown); self.width];
            self.height
        ];
        let mut curr_cell = start_cell;

        let dx = vec![-1, 1, 0, 0];
        let dy = vec![0, 0, -1, 1];
        while !self.is_escape(curr_cell) {
            self.grid[curr_cell.1][curr_cell.0] = CellType::Path;
            let dir = gen_range(0, 4);
            curr_cell.0 = (curr_cell.0 as isize + dx[dir]) as usize;
            curr_cell.1 = (curr_cell.1 as isize + dy[dir]) as usize;
        }
        self.grid[curr_cell.1][curr_cell.0] = CellType::Escape;
    }

    /// Bfs generation tactic works simmilary to Dfs tactic but instead
    /// of always using one node which goes further and further, we use
    /// multiple modes such that we have a more spread out maze.
    fn bfs_maze(&mut self, start_cell: (usize, usize)) {
        self.grid = vec![
            vec![CellType::Wall(WallType::Unknown, Direction::Unknown); self.width];
            self.height
        ];

        let dx = vec![-1, 1, 0, 0];
        let dy = vec![0, 0, -1, 1];
        let mut cells: VecDeque<(usize, usize)> = VecDeque::new();
        cells.push_back(start_cell);

        while !cells.is_empty() {
            let cell = cells.pop_front().unwrap();
            if self.is_escape(cell) {
                self.grid[cell.1][cell.0] = CellType::Escape;
                continue;
            }

            self.grid[cell.1][cell.0] = CellType::Path;
            let dir = gen_range(0, 4);
            let new_cell = (
                (cell.0 as isize + dx[dir]) as usize,
                (cell.1 as isize + dy[dir]) as usize,
            );
            cells.push_back(new_cell);
        }
    }

    fn kruskal_maze() {
        todo!();
    }

    /// Checks if the `cell` is on the edges of the grid.
    fn is_escape(&self, cell: (usize, usize)) -> bool {
        cell.0 == self.width - 1 || cell.1 == self.height - 1 || cell.0 == 0 || cell.1 == 0
    }
}

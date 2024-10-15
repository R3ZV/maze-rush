# Maze Rush

Maze Rush aims to be a fun 1 vs 1 movement game where you are stuck
in a maze and compete with another player to be the first to escape the
maze as fast as possible, but watch out you have a limited time to escape
the maze or otherwise both of you die.

# Goals

- Web based game
- Matchmaking
- Create a lobby to compete with friends
- Singleplayer mode
- Fluide movement
- Maybe some power ups
- Some sort of score system (wins, win %, etc.)
- Leaderboard
- Get coins when you win to buy skins for your character, map

# Build from source

In order to build the project from source you will first have to make
sure you have `nix-shell` installed on your system.

In your terminal of choice you can run:
```bash
git clone git@github.com:R3ZV/maze-rush.git

cd maze-rush

# If you have direnv installed you could use
direnv allow

# If you don't have dirnev
nix-shell shell.nix

# Now you can build and run the project
cargo run
```

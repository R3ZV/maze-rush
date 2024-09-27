# Maze Rush

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
zig build run
```

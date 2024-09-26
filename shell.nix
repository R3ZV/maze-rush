{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
    buildInputs = with pkgs; [
        xorg.libX11
        libGL
    ];

    LD_LIBRARY_PATH = builtins.concatStringsSep ":" [
        "${pkgs.xorg.libX11}/lib"
        "${pkgs.libGL}/lib"
    ];
}


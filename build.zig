const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "maze-rush",
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    // Raylib dep
    const raylib_dep = b.dependency("raylib", .{
        .target = target,
        .optimize = optimize,
    });

    exe.addIncludePath(raylib_dep.path("include"));
    exe.addLibraryPath(raylib_dep.path("lib"));
    exe.linkSystemLibrary("raylib");
    exe.linkLibC();

    b.installArtifact(exe);

    // Step to run the binary after build
    const run_exe = b.addRunArtifact(exe);
    const run_step = b.step("run", "Run the application");
    run_step.dependOn(&run_exe.step);

    // Add unit testing
    const exe_tests = b.addTest(.{
        .root_source_file = b.path("src/main.zig"),
        .target = target,
        .optimize = optimize,
    });

    const run_exe_tests = b.addRunArtifact(exe_tests);

    const test_step = b.step("test", "Run the application tests");
    test_step.dependOn(&run_exe_tests.step);
}

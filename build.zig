const std = @import("std");

pub fn build_glfw(b: *std.Build) !void {
    const glfw_prebuild = b.addSystemCommand(&.{
        "cmake",
        "-S",
        "deps/glfw",
        "-B",
        "deps/glfw/build",
        "-DCMAKE_MSVC_RUNTIME_LIBRARY=MultiThreaded",
        "-DUSE_MSVC_RUNTIME_LIBRARY_DLL=OFF",
    });
    try glfw_prebuild.step.make();

    const glfw = b.addSystemCommand(&.{
        "cmake",
        "--build",
        "deps/glfw/build",
        "-j",
        "--target",
        "ALL_BUILD",
        "--config",
        "Release",
    });
    try glfw.step.make();
}

pub fn build(b: *std.Build) !void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    try build_glfw(b);

    const exe = b.addExecutable(.{
        .name = "glfw-playground",
        .target = target,
        .optimize = optimize,
    });

    const source_files = .{"src/main.c"};
    const cflags = .{ "-std=c99", "-pedantic", "-W", "-Wall", "-Wextra" };

    exe.addCSourceFiles(&source_files, &cflags);

    exe.addIncludePath("deps/glfw/include");
    exe.addLibraryPath("deps/glfw/build/src/Release");

    exe.linkLibC();
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("opengl32");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("shell32");

    exe.install();

    const run_cmd = exe.run();

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

const std = @import("std");

pub fn build(b: *std.Build) anyerror!void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const exe = b.addExecutable(.{
        .name = "glfw-playground",
        .target = target,
        .optimize = optimize,
    });

    const source_files = .{"src/main.cc"};
    const cflags = .{ "-std=c99", "-pedantic", "-W", "-Wall", "-Wextra" };
    const cxxflags = .{ "-std=c++11", "-pedantic", "-W", "-Wall", "-Wextra" };

    exe.addCSourceFiles(&source_files, &cxxflags);

    exe.addIncludePath(.{ .path = "deps/glad/include" });
    exe.addCSourceFile(.{ .file = .{ .path = "deps/glad/src/glad.c" }, .flags = &cflags });

    exe.addIncludePath(.{ .path = "deps/glfw/include" });
    exe.addLibraryPath(.{ .path = "deps/glfw/build/src/Release" });

    exe.linkLibC();
    exe.linkSystemLibrary("glfw3");
    exe.linkSystemLibrary("opengl32");
    exe.linkSystemLibrary("user32");
    exe.linkSystemLibrary("gdi32");
    exe.linkSystemLibrary("shell32");

    b.installArtifact(exe);

    const run_cmd = b.addRunArtifact(exe);

    run_cmd.step.dependOn(b.getInstallStep());

    if (b.args) |args| {
        run_cmd.addArgs(args);
    }

    const run_step = b.step("run", "Run the app");
    run_step.dependOn(&run_cmd.step);
}

const std = @import("std");

pub fn build(b: *std.build.Builder) void {
    const exe = b.addExecutable(.{
        .name = "zweb",
        .root_source_file = .{ .path = "main.zig" },
    });

    exe.linkLibC();
    exe.linkSystemLibrary("gtk4");
    exe.linkSystemLibrary("webkitgtk-6.0");
    exe.install();
}

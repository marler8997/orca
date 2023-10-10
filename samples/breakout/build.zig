const std = @import("std");

pub fn build(b: *std.Build) void {
    //const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});
    const wasm_target = std.zig.CrossTarget{
        .cpu_arch = .wasm32,
        .os_tag = .freestanding,
        .cpu_features_add = std.Target.wasm.featureSet(&.{.bulk_memory}),
    };

    const app = b.addSharedLibrary(.{
        .name = "breakout",
        .target = wasm_target,
        .optimize = optimize,
    });
    app.rdynamic = true;
    app.disable_sanitize_c = true;
    app.defineCMacro("__ORCA__", null);
    app.addIncludePath(.{ .path = "../../src" });
    app.addIncludePath(.{ .path = "../../src/ext" });
    app.addIncludePath(.{ .path = "../../src/libc-shim/include" });
    app.addCSourceFiles(&.{
        "src/main.c",
    }, &.{
        //"-D__ORCA__",
        //"-Wl,--no-entry",
    });

    const cflags = [_][]const u8{
        "-O2", // works around undefined symbol on __fpclassifyl
    };
    app.addCSourceFile(.{
        .file = .{ .path = "../../src/orca.c" },
        .flags = &cflags,
    });
    app.addCSourceFiles(&libc_shim_files, &cflags);
    
//set wasmFlags=--target=wasm32^
//       --no-standard-libraries ^
//       -mbulk-memory ^
//       -g -O2 ^
//       -Wl,--no-entry ^
//       -Wl,--export-dynamic ^
//       -isystem %STDLIB_DIR%\include ^
//       -I%ORCA_DIR%\src ^
//       -I%ORCA_DIR%\src\ext
    
    const bundle = b.addSystemCommand(&.{
        "python3",
        "../../orca",
        "bundle",
        "--orca-dir", "../..",
        "--name", "Breakout",
        "--icon", "icon.png",
        "--resource-dir", "data",
    });
    bundle.addArtifactArg(app);
    b.default_step.dependOn(&bundle.step);
}

const libc_shim_files = [_][]const u8{
    "../../src/libc-shim/src/__cos.c",
    "../../src/libc-shim/src/__cosdf.c",
    "../../src/libc-shim/src/__errno_location.c",
    "../../src/libc-shim/src/__math_divzero.c",
    "../../src/libc-shim/src/__math_divzerof.c",
    "../../src/libc-shim/src/__math_invalid.c",
    "../../src/libc-shim/src/__math_invalidf.c",
    "../../src/libc-shim/src/__math_oflow.c",
    "../../src/libc-shim/src/__math_oflowf.c",
    "../../src/libc-shim/src/__math_uflow.c",
    "../../src/libc-shim/src/__math_uflowf.c",
    "../../src/libc-shim/src/__math_xflow.c",
    "../../src/libc-shim/src/__math_xflowf.c",
    "../../src/libc-shim/src/__rem_pio2.c",
    "../../src/libc-shim/src/__rem_pio2_large.c",
    "../../src/libc-shim/src/__rem_pio2f.c",
    "../../src/libc-shim/src/__sin.c",
    "../../src/libc-shim/src/__sindf.c",
    "../../src/libc-shim/src/__tan.c",
    "../../src/libc-shim/src/__tandf.c",
    "../../src/libc-shim/src/abs.c",
    "../../src/libc-shim/src/acos.c",
    "../../src/libc-shim/src/acosf.c",
    "../../src/libc-shim/src/asin.c",
    "../../src/libc-shim/src/asinf.c",
    "../../src/libc-shim/src/atan.c",
    "../../src/libc-shim/src/atan2.c",
    "../../src/libc-shim/src/atan2f.c",
    "../../src/libc-shim/src/atanf.c",
    "../../src/libc-shim/src/cbrt.c",
    "../../src/libc-shim/src/cbrtf.c",
    "../../src/libc-shim/src/ceil.c",
    "../../src/libc-shim/src/cos.c",
    "../../src/libc-shim/src/cosf.c",
    "../../src/libc-shim/src/exp.c",
    "../../src/libc-shim/src/exp2f_data.c",
    "../../src/libc-shim/src/exp_data.c",
    "../../src/libc-shim/src/expf.c",
    "../../src/libc-shim/src/fabs.c",
    "../../src/libc-shim/src/fabsf.c",
    "../../src/libc-shim/src/floor.c",
    "../../src/libc-shim/src/fmod.c",
    "../../src/libc-shim/src/log.c",
    "../../src/libc-shim/src/log2.c",
    "../../src/libc-shim/src/log2_data.c",
    "../../src/libc-shim/src/log2f.c",
    "../../src/libc-shim/src/log2f_data.c",
    "../../src/libc-shim/src/log_data.c",
    "../../src/libc-shim/src/logf.c",
    "../../src/libc-shim/src/logf_data.c",
    "../../src/libc-shim/src/pow.c",
    "../../src/libc-shim/src/powf.c",
    "../../src/libc-shim/src/powf_data.c",
    "../../src/libc-shim/src/scalbn.c",
    "../../src/libc-shim/src/sin.c",
    "../../src/libc-shim/src/sinf.c",
    "../../src/libc-shim/src/sqrt.c",
    "../../src/libc-shim/src/sqrt_data.c",
    "../../src/libc-shim/src/sqrtf.c",
    "../../src/libc-shim/src/string.c",
    "../../src/libc-shim/src/tan.c",
    "../../src/libc-shim/src/tanf.c",
};

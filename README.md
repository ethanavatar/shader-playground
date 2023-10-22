# shader playground

It's just like [Shadertoy](https://www.shadertoy.com/) but as a command line tool.

This is a toy project of mine, so no guarantees are made about its quality or functionality. It is also bound to change suddenly.

## Usage

```bash
$ shader-playground.exe
Expected 1 arguments, got 0
Usage: $ shader-playground.exe path\to\fragment.glsl
```

There are some written fragment shaders in the `examples` directory.

This one is an adaptation of the default program when you create a new shader in Shadertoy:

```bash
$ shader-playground examples/shadertoy_gradient.glsl
```

## Building from Source

This program depends on these things:
- [GLFW](https://www.glfw.org/) as the graphics framework
    - This framework is built with [CMake](https://cmake.org/)
- [GLAD](https://glad.dav1d.de/) to manage OpenGL loading
    - This program runs using [python](https://www.python.org/)
- [zig 0.11.0](https://ziglang.org/) as the build system

Cloning recursively will fetch GLFW as a submodule:

```bash
$ git clone --recursive https://github.com/ethanavatar/shader-playground.git
```

Use CMake to build GLFW:

```bash
# Generate build files for your platform
$ cmake -B deps/glfw/build -S deps/glfw/

# Build the library binaries (`-j` for multithreading)
$ cmake --build deps/glfw/build -j
```

Generate GLAD C-Bindings:

```bash
# Install/upgrade glad
$ pip install glad --upgrade

# Generate C bindings
$ python -m glad --profile core --out-path deps/glad --generator c --api gl=3.3 --spec gl
```

Build shader playground with zig:

```bash
$ zig build -Dtarget=native-native-msvc -Doptimize=ReleaseSafe
```

The `build.zig` has been made with only windows in mind. So It would require modifications for other platforms.

You can also run the program from zig-build:

```bash
$ zig build run -Dtarget=native-native-msvc -Doptimize=ReleaseSafe -- examples/shadertoy_gradient.glsl
```

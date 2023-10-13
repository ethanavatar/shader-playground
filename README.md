# glfw-playground

Clone recursively.

```bash
$ git clone --recursive https://github.com/ethanavatar/glfw-playground.git
```

Generate GLAD C-Bindings:
```bash
$ pip install glad
$ python -m glad --profile core --out-path deps/glad --generator c --api gl=3.3 --spec gl
```


Build and run with [zig](https://ziglang.org/).

```bash
$ zig build run -Dtarget=native-native-msvc --
Expected 1 arguments, got 0
Usage: $ <program> path\to\fragment.glsl

$ zig build run -Dtarget=native-native-msvc -- examples\shadertoy_rainbow.glsl
```


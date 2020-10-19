Raytracer in One Weekend - Odin
===
A port
---

A port of my zig version of [Ray Tracing in One Weekend](https://raytracing.github.io/books/RayTracingInOneWeekend.html) to try out Odin. Currently Odin with -opt:3 runs in 13 seconds, while the zig version in -Drelease-fast runs in 2-3 seconds. Not sure why yet, code is similar though the multi-return values in Odin probably result in many more copies of data (which I would hope are relatively optimized away).

A big speed boost in the Zig version is setting up the random ahead of time, not sure if rand in Odin is slow or fast by default

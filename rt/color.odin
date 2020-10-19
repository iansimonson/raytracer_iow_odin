package rt

import "core:math"
import "core:math/linalg"

Color :: distinct [3]f64;

// need to figure out how to do this in Odin
write_color :: proc(streamf: $T, ctx: $S, pixel_color: Color) {
    scaled := linalg.clamp((pixel_color * 255.999), Color{0, 0, 0}, Color{255, 255, 255});
    streamf(ctx, "{} {} {}\n", i32(scaled[0]), i32(scaled[1]), i32(scaled[2]));
}

write_color_multi_sample :: proc(streamf: $T, ctx: $S, pixel_color: Color, samples_per_pixel: i32) {
    scale := 1.0 / f64(samples_per_pixel);

    scaled_pixel := linalg.clamp(linalg.sqrt(pixel_color * scale), Color{0, 0, 0}, Color{1, 1, 1});
    write_color(streamf, ctx, scaled_pixel);
}

normalize :: proc(color: Color, scale: f64) -> Color {
    return color / scale;
}

normalize_float :: proc(value: f64, scale: f64) -> f64 {
    return value / scale;
}

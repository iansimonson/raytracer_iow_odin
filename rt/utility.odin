package rt

import "core:math"
import "core:math/rand"

infinity : f64 : 0x7ff0000000000000;

pi :: 3.1415926535897932385;

Degrees :: distinct f64;
Radians :: distinct f64;

degrees_to_radians :: proc(degs: Degrees) -> Radians {
    return Radians(f64(degs) * pi / 180.0);
}

@(private = "file")
tan_deg :: proc(angle: Degrees) -> f64 {
    return tan_rad(degrees_to_radians(angle));
}

@(private = "file")
tan_rad :: proc(angle: Radians) -> f64 {
    return math.tan(f64(angle));
}

tan :: proc{tan_deg, tan_rad};



random :: proc() -> f64 {
    return rand.float64();
}

random_in_range :: proc(min, max: f64) -> f64 {
    return min + (max - min) * random();
}

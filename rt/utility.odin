package rt

import "core:math"
import "core:math/rand"

infinity : f64 : 0x7ff0000000000000;

pi :: 3.1415926535897932385;

random :: proc() -> f64 {
    return rand.float64();
}

random_in_range :: proc(min, max: f64) -> f64 {
    return min + (max - min) * random();
}

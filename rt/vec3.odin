package rt

import "core:math"

Vec3 :: distinct [3]f64;

get_x :: proc(vec: Vec3) -> f64 {
    return vec[0];
}

get_y :: proc(vec: Vec3) -> f64 {
    return vec[1];
}

get_z :: proc(vec: Vec3) -> f64 {
    return vec[2];
}

dot :: proc(lhs, rhs: Vec3) -> f64 {
    comp := lhs * rhs;
    return comp[0] + comp[1] + comp[2];
}

cross :: proc(lhs, rhs: Vec3) -> Vec3 {
    return Vec3{lhs[1] * rhs[2] - lhs[2] * rhs[1],
        lhs[2] * rhs[0] - lhs[0] * rhs[2],
        lhs[0] * rhs[1] - lhs[1] * rhs[0]
    };
}

magnitude :: proc(vec: Vec3) -> f64 {
    return math.sqrt(dot(vec, vec));
}

unit_vector :: proc(vec: Vec3) -> (res: Vec3) {
    res = vec;
    res /= magnitude(res);
    return;
}

random_unit_vector :: proc() -> Vec3 {
    a := random_in_range(0, 2 * pi);
    z := random_in_range(-1, 1);
    r := math.sqrt(1 - z*z);
    return Vec3{r * math.cos(a), r * math.sin(a), z};
}

random_in_unit_disk :: proc() -> Vec3 {
    for {
        vec := Vec3{random_in_range(-1, 1), random_in_range(-1, 1), 0};
        if dot(vec, vec) >= 1 {
            continue;
        }

        return vec;
    }
}

reflect_around_vector :: proc(to_reflect: Vec3, reflect_around: Vec3) -> Vec3 {
    magnitude_b := dot(reflect_around, to_reflect);
    return to_reflect - (reflect_around * magnitude_b * 2);
}

refract :: proc(light: Vec3, normal: Vec3, etai_over_etat: f64) -> Vec3 {
    cos_theta := dot(light * -1, normal);
    r_out_parallel := (normal * cos_theta + light) * etai_over_etat;
    r_out_perp := normal * (-1 * math.sqrt(1.0 - dot(r_out_parallel, r_out_parallel)));
    return r_out_parallel + r_out_perp;
}

Point3 :: distinct [3]f64;


package rt

Camera :: struct {
    origin: Point3,
    horizontal: Vec3,
    vertical: Vec3,
    lower_left_corner: Point3,
    u: Vec3,
    v: Vec3,
    w: Vec3,
    lens_radius: f64,
}


make_camera :: proc(look_from: Point3, look_at: Point3, vup: Vec3, vertical_fov: Degrees, aspect_ratio: f64, aperature: f64, focus_distance: f64) -> Camera {

    theta := degrees_to_radians(vertical_fov);
    h := tan(theta / 2);
    viewport_height := 2.0 * h;
    viewport_width := viewport_height * aspect_ratio;

    w := unit_vector(Vec3(look_from - look_at));
    u := unit_vector(cross(vup, w));
    v := cross(w, u);

    origin := look_from;
    horizontal := u * (viewport_width * focus_distance);
    vertical := v * (viewport_height * focus_distance);
    llc := Point3(Vec3(origin) - (horizontal / 2) - (vertical / 2) - (w * focus_distance));

    lens_radius := aperature / 2;

    return Camera{origin = origin, horizontal = horizontal, vertical = vertical, lower_left_corner = llc, u = u, v = v, w = w, lens_radius = lens_radius};
}

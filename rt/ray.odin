package rt

Ray :: struct {
    origin: Point3,
    direction: Vec3,
}

ray_at :: proc(ray: Ray, t: f64) -> Point3 {
    return Point3(Vec3(ray.origin) + (ray.direction * t));
}

package rt

import "core:math"

HitRecord :: struct {
    p: Point3,
    normal: Vec3,
    t: f64,
    front_face: bool,
    material: Material
}

set_face_normal :: proc(hit_record: ^HitRecord, ray: Ray, norm: Vec3) {
    hit_record.front_face = dot(ray.direction, norm) < 0;
    if hit_record.front_face {
        hit_record.normal = norm;
    } else {
        hit_record.normal = -1 * norm;
    }

}

Sphere :: struct {
    center: Point3,
    radius: f64,
    material: Material,
}

hit_list :: proc(sphere_list: []Sphere, ray: Ray, t_min, t_max: f64, hit_record: ^HitRecord) -> bool {
    temp_record : HitRecord = ---;
    hit_something := false;
    closest := t_max;

    for sphere in sphere_list {
        hit := hit_sphere(sphere, ray, t_min, closest, &temp_record);
        if hit {
            hit_something = true;
            closest = temp_record.t;
            hit_record^ = temp_record;
        }
    }

    return hit_something;
}

hit_sphere :: proc(sphere: Sphere, ray: Ray, t_min, t_max: f64, hit_record: ^HitRecord) -> bool {
    oc := Vec3(ray.origin - sphere.center);
    a := dot(ray.direction, ray.direction);
    half_b := dot(oc, ray.direction);
    c := dot(oc, oc) - (sphere.radius * sphere.radius);
    discriminant := (half_b * half_b) - (a * c);
    if (discriminant > 0) {
        disc_root := math.sqrt(discriminant);
        neg_root := (-half_b - disc_root) / a;
        if neg_root < t_max && neg_root > t_min {
            hit_record.t = neg_root;
            hit_record.p = ray_at(ray, hit_record.t);
            outward_normal := Vec3((hit_record.p - sphere.center) / sphere.radius);
            set_face_normal(hit_record, ray, outward_normal);
            return true;
        }

        pos_root := (-half_b + disc_root) / a;
        if pos_root < t_max && pos_root > t_min {
            hit_record.t = pos_root;
            hit_record.p = ray_at(ray, hit_record.t);
            outward_normal := Vec3((hit_record.p - sphere.center) / sphere.radius);
            set_face_normal(hit_record, ray, outward_normal);
            return true;
        }

    }

    return false;
}

hit :: proc{hit_sphere, hit_list};

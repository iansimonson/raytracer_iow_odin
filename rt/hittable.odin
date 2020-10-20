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

hit_list :: proc(sphere_list: []Sphere, ray: Ray, t_min, t_max: f64, hit_record: HitRecord) -> (HitRecord, bool) {
    new_record : HitRecord; 
    temp_record : HitRecord;
    hit_something := false;
    closest := t_max;

    for sphere in sphere_list {
        t_record, hit := hit_sphere(sphere, ray, t_min, closest, temp_record);
        temp_record = t_record;
        if hit {
            hit_something = true;
            closest = t_record.t;
            new_record = t_record;
        }
    }

    return new_record, hit_something;
}

hit_sphere :: proc(sphere: Sphere, ray: Ray, t_min, t_max: f64, hit_record: HitRecord) -> (HitRecord, bool) {
    oc := Vec3(ray.origin - sphere.center);
    a := dot(ray.direction, ray.direction);
    half_b := dot(oc, ray.direction);
    c := dot(oc, oc) - (sphere.radius * sphere.radius);
    discriminant := (half_b * half_b) - (a * c);
    if (discriminant > 0) {
        disc_root := math.sqrt(discriminant);
        neg_root := (-half_b - disc_root) / a;
        if neg_root < t_max && neg_root > t_min {
            updated_hr := HitRecord{t = neg_root, p = ray_at(ray, neg_root), material = sphere.material};
            outward_normal := Vec3((updated_hr.p - sphere.center) / sphere.radius);
            set_face_normal(&updated_hr, ray, outward_normal);
            return updated_hr, true;
        }

        pos_root := (-half_b + disc_root) / a;
        if pos_root < t_max && pos_root > t_min {
            updated_hr := HitRecord{t = pos_root, p = ray_at(ray, pos_root), material = sphere.material};
            outward_normal := Vec3((updated_hr.p - sphere.center) / sphere.radius);
            set_face_normal(&updated_hr, ray, outward_normal);
            return updated_hr, true;
        }

    }

    return hit_record, false;
}

hit :: proc{hit_sphere, hit_list};

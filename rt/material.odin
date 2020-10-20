package rt

import "core:math"

Lambertian :: struct {
    albedo: Color,
}

Metal :: struct {
    albedo: Color,
}

Dielectric :: struct {
    ref_idx: f64,
}

Material :: union {
    Lambertian,
    Metal,
    Dielectric,
}

@(private = "file")
scatter_lambertian :: proc(material: Lambertian, ray: Ray, hit_record: HitRecord, attenuation: ^Color, scattered: ^Ray) -> bool {
    scattered_direction := hit_record.normal + random_unit_vector();
    scattered^ = Ray{origin = hit_record.p, direction = scattered_direction};
    attenuation^ = material.albedo;
    return true;
}

@(private = "file")
scatter_metal :: proc(material: Metal, ray: Ray, hit_record: HitRecord, attenuation: ^Color, scattered: ^Ray) -> bool {
    reflected := reflect_around_vector(unit_vector(ray.direction), hit_record.normal);
    scattered^ = Ray{origin = hit_record.p, direction = reflected};
    attenuation^ = material.albedo;
    return dot(scattered.direction, hit_record.normal) > 0;
}

@(private = "file")
scatter_dielectric :: proc(material: Dielectric, ray: Ray, hit_record: HitRecord, attenuation: ^Color, scattered: ^Ray) -> bool {
    schlick :: proc(cos: f64, ridx: f64) -> f64 {
        r0 := (1 - ridx) / (1 + ridx);
        r1 := r0 * r0;
        return r1 + (1-r0)*math.pow(1 - cos, 5);
    }

    etai_over_etat := proc(hr: HitRecord, idx: f64) -> f64{
        if hr.front_face { return 1.0 / idx; } else { return idx; }
    }(hit_record, material.ref_idx);

    unit_direction := unit_vector(ray.direction);
    cos_theta := min(dot(unit_direction * -1, hit_record.normal), 1);
    sin_theta := math.sqrt(1 - cos_theta * cos_theta);
    reflect_probability := schlick(cos_theta, etai_over_etat);

    direction: Vec3;
    if etai_over_etat * sin_theta > 1 || random() < reflect_probability {
        direction = reflect_around_vector(unit_direction, hit_record.normal);
    } else {
        direction = refract(unit_direction, hit_record.normal, etai_over_etat);
    }

    scattered^ = Ray{origin = hit_record.p, direction = direction};
    attenuation^ = Color{1, 1, 1};
    return true;
}

@(private = "file")
scatter_material :: proc{scatter_lambertian, scatter_metal, scatter_dielectric};

scatter :: proc(material: Material, ray: Ray, hit_record: HitRecord, attenuation: ^Color, scattered: ^Ray) -> bool {
    switch mat in material {
    case Lambertian: return scatter_material(mat, ray, hit_record, attenuation, scattered);
    case Metal: return scatter_material(mat, ray, hit_record, attenuation, scattered);
    case Dielectric: return scatter_material(mat, ray, hit_record, attenuation, scattered);
    }

    return false;
}

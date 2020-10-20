package main

import "core:fmt"
import "core:math"
import "core:os"
import "core:strings"
import "rt"

swap :: proc(left, right: $T) -> (T, T) {
    return right, left;
}

main :: proc() {
    aspect_ratio : f64 : 16.0 / 9.0;
    image_width : i32 : 384;
    image_height : i32 : i32(f64(image_width) / aspect_ratio);
    samples_per_pixel : i32 : 100;
    max_depth : i32 : 50;

    lambertian := rt.Lambertian{albedo = rt.Color{0.1, 0.2, 0.5}};
    lambertian2 := rt.Lambertian{albedo = rt.Color{0.8, 0.8, 0}};
    metal := rt.Metal{albedo = rt.Color{0.8, 0.6, 0.2}};
    metal2 := rt.Metal{albedo = rt.Color{0.8, 0.8, 0.8}};
    glass := rt.Dielectric{ref_idx = 1.5};

    sphere := rt.Sphere{center = rt.Point3{0, 0, -1}, radius = 0.5, material = lambertian};
    ground_sphere := rt.Sphere{center = rt.Point3{0, -100.5, -1}, radius = 100, material = lambertian2};
    metal_sphere := rt.Sphere{center = rt.Point3{1, 0, -1}, radius = 0.5, material = metal};
    metal_sphere_2 := rt.Sphere{center = rt.Point3{-1, 0, -1}, radius = -0.5, material = glass};

    world := make([dynamic]rt.Sphere, 4);
    append(&world, sphere, ground_sphere, metal_sphere, metal_sphere_2);
    defer delete(world);

    look_from := rt.Point3{3, 3, 2};
    look_at := rt.Point3{0, 0, -1};
    vup := rt.Vec3{0, 1, 0};
    dist_to_focus := rt.magnitude(rt.Vec3(look_from - look_at));
    aperature := 2.0;
    camera := rt.make_camera(look_from, look_at, vup, 20, aspect_ratio, aperature, dist_to_focus);

    outstream := strings.make_builder();

    fmt.sbprintf(&outstream, "P3\n{} {}\n255\n", image_width, image_height);
    for j : i32 = image_height - 1; j >= 0; j -= 1 {
        fmt.fprintf(os.stderr, "\rScanlines remaining: {}", j);
        for i : i32 = 0; i < image_width; i += 1 {
            pixel_color := rt.Color{0, 0, 0};
            for s : i32 = 0; s < samples_per_pixel; s += 1 {
                u := rt.normalize_float(f64(i) + rt.random(), f64(image_width - 1));
                v := rt.normalize_float(f64(j) + rt.random(), f64(image_height - 1));

                r := get_ray(camera, u, v);
                r_color := ray_color(r, world[:], max_depth);

                pixel_color += r_color;
            }

            rt.write_color_multi_sample(fmt.sbprintf, &outstream, pixel_color, samples_per_pixel);
        }
    }

    str := strings.to_string(outstream);
    defer delete(str);
    fmt.print(str);
}

get_ray :: proc(camera: rt.Camera, u: f64, v: f64) -> rt.Ray {
    rd := rt.random_in_unit_disk() * camera.lens_radius;
    offset := (camera.u * rt.get_x(rd)) + (camera.v * rt.get_y(rd));
    direction_vec := rt.Vec3(camera.lower_left_corner) + (camera.horizontal * u) + (camera.vertical * v) - rt.Vec3(camera.origin) - offset;

    return rt.Ray{origin = rt.Point3(rt.Vec3(camera.origin) + offset), direction = direction_vec};
}

ray_color :: proc(ray: rt.Ray, world: []rt.Sphere, depth: i32) -> rt.Color {
    if depth <= 0 { return rt.Color{0, 0, 0}; }

    hit_record : rt.HitRecord;

    if t_record, did_hit := rt.hit(world, ray, 0.001, rt.infinity, hit_record); did_hit {
        hit_record = t_record;
        if attenuation, scattered, ok := rt.scatter(hit_record.material, ray, hit_record); ok {
            next_rc := ray_color(scattered, world, depth - 1);
            return next_rc * attenuation;
        }

        return rt.Color{0, 0, 0};
    } else {
        unit_direction := rt.unit_vector(ray.direction);
        t := 0.5 * (rt.get_y(unit_direction) + 1.0);
        return (rt.Color{1, 1, 1} * (1.0 - t)) + (rt.Color{0.5, 0.7, 1.0} * t);
    }
}

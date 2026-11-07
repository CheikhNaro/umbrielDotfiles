vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    float pixel_size = mix(0.0005, 0.10 + umbriel_random_seed.x * 0.04, p * p);
    vec2 pixelated_uv = floor(uv / pixel_size) * pixel_size + pixel_size * 0.5;

    vec4 color = umbriel_sample(pixelated_uv);

    float alpha = smoothstep(1.0, 0.5, p);

    return color * alpha;
}

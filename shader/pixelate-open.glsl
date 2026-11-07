vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    float pixel_size = mix(0.06 + umbriel_random_seed.x * 0.04, 0.0005, p * p);
    vec2 pixelated_uv = floor(uv / pixel_size) * pixel_size + pixel_size * 0.5;

    vec4 color = umbriel_sample(pixelated_uv);

    vec2 center = uv - 0.5;
    float dist = length(center);
    float reveal = smoothstep(0.0, 0.5, p) * smoothstep(dist * 0.8, dist * 0.8 - 0.3, (1.0 - p));

    float alpha = smoothstep(0.0, 0.3, p);
    return color * alpha;
}

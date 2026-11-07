vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    vec2 center = vec2(0.5, 0.5);
    float scale = mix(1.0, 0.95, p);
    vec2 scaled_uv = (uv - center) / scale + center;

    vec4 color = umbriel_sample(scaled_uv);

    float alpha = smoothstep(1.0, 0.2, p);

    return color * alpha;
}

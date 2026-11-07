// Ported from skwd-wall crosswarp transition

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    float x = smoothstep(0.0, 1.0, (p * 2.0 + uv.x - 1.0));
    vec2 warped = clamp((uv - 0.5) * x + 0.5, vec2(0.0), vec2(1.0));

    vec4 win = umbriel_sample(warped);

    float in_bounds = step(0.0, uv.x) * step(uv.x, 1.0) * step(0.0, uv.y) * step(uv.y, 1.0);
    return win * x * in_bounds;
}

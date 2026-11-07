// Ported from skwd-wall directional transition

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    vec4 win = umbriel_sample(uv);

    vec2 dir = vec2(0.0, 1.0);
    vec2 q = uv + p * sign(dir);
    float inside = step(0.0, q.y) * step(q.y, 1.0) * step(0.0, q.x) * step(q.x, 1.0);

    return win * (1.0 - inside);
}

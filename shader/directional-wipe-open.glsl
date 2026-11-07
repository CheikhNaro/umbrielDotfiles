// Ported from skwd-wall directional-wipe transition

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    vec4 win = umbriel_sample(uv);

    vec2 dir = vec2(1.0, -1.0);
    float smoothness = 0.5;
    vec2 center = vec2(0.5, 0.5);
    vec2 v = normalize(dir);
    v /= abs(v.x) + abs(v.y);
    float d = v.x * center.x + v.y * center.y;
    float reveal = (1.0 - step(p, 0.0)) *
        (1.0 - smoothstep(-smoothness, 0.0, v.x * uv.x + v.y * uv.y - (d - 0.5 + p * (1.0 + smoothness))));

    return win * reveal;
}

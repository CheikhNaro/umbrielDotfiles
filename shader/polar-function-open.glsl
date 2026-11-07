// Ported from skwd-wall polar-function transition

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    vec4 win = umbriel_sample(uv);

    int segments = 5;
    float angle = atan(uv.y - 0.5, uv.x - 0.5);
    float radius = (cos(float(segments) * angle) + 4.0) / 4.0;
    float difference = length(uv - vec2(0.5, 0.5));
    float reveal = step(difference, radius * p);

    return win * reveal;
}

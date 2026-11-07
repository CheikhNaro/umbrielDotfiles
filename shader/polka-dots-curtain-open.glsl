// Ported from skwd-wall polka-dots-curtain transition

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    vec4 win = umbriel_sample(uv);

    float dots = 20.0;
    vec2 center = vec2(0.0, 0.0);
    float reveal = step(distance(fract(uv * dots), vec2(0.5, 0.5)), p / max(distance(uv, center), 0.0001));

    return win * reveal;
}

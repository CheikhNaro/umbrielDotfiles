// Ported from skwd-wall fadecolor transition

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    float colorPhase = 0.4;

    vec4 win = umbriel_sample(uv);

    float reveal = smoothstep(colorPhase, 1.0, p);
    return win * reveal;
}

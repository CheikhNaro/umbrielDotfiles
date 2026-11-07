// Ported from skwd-wall overexposure transition

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    float strength = 0.6;
    float PI = 3.141592653589793;

    vec4 win = umbriel_sample(uv);

    float to_m = p + sin(PI * p) * strength;
    vec4 mixed = vec4(
        win.r * win.a * to_m,
        win.g * win.a * to_m,
        win.b * win.a * to_m,
        win.a * p
    );

    return mixed;
}

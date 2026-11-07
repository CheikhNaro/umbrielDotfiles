// Ported from skwd-wall flyeye transition

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    float sz = 0.04;
    float zoom = 50.0;
    float inv = 1.0 - p;
    vec2 disp = sz * vec2(cos(zoom * uv.x), sin(zoom * uv.y));
    vec2 sample_uv = uv + inv * disp;

    vec4 win = umbriel_sample(sample_uv);

    return win * p;
}

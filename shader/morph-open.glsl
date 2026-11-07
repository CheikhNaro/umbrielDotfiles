// Ported from skwd-wall morph transition

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    float strength_v = 0.15;

    vec4 cb = umbriel_sample(uv);
    vec2 ob = ((cb.rg + cb.b) * 0.5) * 2.0 - 1.0;
    vec2 oc = ob * strength_v;
    float w1 = 1.0 - p;

    vec2 sample_uv = uv - oc * w1;
    vec4 win = umbriel_sample(sample_uv);

    return win * p;
}

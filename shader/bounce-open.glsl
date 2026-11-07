// Ported from skwd-wall bounce transition

vec4 animation(vec2 uv) {
    float p = 1.0 - umbriel_clamped_progress;
    float PI = 3.14159265358;
    float bounces = 3.0;

    float time = p;
    float stime = sin(time * PI / 2.0);
    float phase = time * PI * bounces;
    float yy = (abs(cos(phase))) * (1.0 - stime);
    float d = uv.y - yy;

    vec2 sample_uv = uv;
    sample_uv.y = uv.y + (1.0 - yy);
    vec4 win = umbriel_sample(sample_uv);

    float reveal = step(d, 0.0);
    return win * reveal;
}

// Ported from skwd-wall crazy-parametric transition

vec4 animation(vec2 uv) {
    float p = 1.0 - umbriel_clamped_progress;
    float a = 4.0;
    float b = 1.0;
    float amplitude = 120.0;
    float smoothness = 0.1;
    vec2 dir = uv - vec2(0.5);
    float dist = length(dir);
    float xx = (a - b) * cos(p) + b * cos(p * ((a / b) - 1.0));
    float yy = (a - b) * sin(p) - b * sin(p * ((a / b) - 1.0));
    vec2 offset = dir * vec2(sin(p * dist * amplitude * xx), sin(p * dist * amplitude * yy)) / smoothness;

    vec4 win = umbriel_sample(uv);

    float reveal = smoothstep(0.2, 1.0, p);
    return win * reveal;
}

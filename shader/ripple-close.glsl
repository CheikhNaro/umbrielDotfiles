// Ported from gl-transitions/ripple.glsl (MIT, gre)

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    float seed = umbriel_random_seed.x * 6.28318;

    float amplitude = 100.0;
    float speed = 50.0;

    vec2 dir = uv - vec2(0.5);
    float dist = length(dir);

    float intensity = p * p;
    vec2 offset = dir * (sin(p * dist * amplitude - p * speed + seed) + 0.5) / 30.0;

    vec2 wuv = uv + offset * intensity;
    vec4 color = umbriel_sample(wuv);

    float alpha = smoothstep(1.0, 0.5, p);
    return color * alpha;
}

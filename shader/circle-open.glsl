// Ported from gl-transitions/circleopen.glsl (MIT, gre)

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    float seed = umbriel_random_seed.x;

    float smoothness = 0.3;
    float SQRT_2 = 1.414213562;

    vec2 center = vec2(0.5 + (seed - 0.5) * 0.15, 0.5 + (seed * 0.7 - 0.35) * 0.15);

    float dist = SQRT_2 * distance(center, uv);
    float m = smoothstep(-smoothness, 0.0, dist - p * (1.0 + smoothness));
    float reveal = 1.0 - m;

    vec4 color = umbriel_sample(uv);

    return color * reveal;
}

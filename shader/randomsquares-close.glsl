// Ported from skwd-wall randomsquares transition

float rs_rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 animation(vec2 uv) {
    float p = 1.0 - umbriel_clamped_progress;
    vec4 win = umbriel_sample(uv);

    vec2 sz = vec2(10.0, 10.0);
    float smoothness = 0.5;
    float r = rs_rand(floor(sz * uv));
    float reveal = smoothstep(0.0, -smoothness, r - (p * (1.0 + smoothness)));

    return win * reveal;
}

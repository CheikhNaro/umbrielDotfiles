// Ported from skwd-wall pixelfade-wave transition

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    float wave_x = (uv.x + uv.y) * 0.5;
    float wave_p = smoothstep(0.0, 1.0, p * 1.6 - wave_x * 0.6);
    float bump = sin(wave_p * 3.14159);
    float blocks = mix(800.0, 8.0, bump);
    vec2 q = floor(uv * blocks) / blocks + 0.5 / blocks;

    vec4 win = umbriel_sample(q);

    float reveal = smoothstep(0.0, 1.0, wave_p);
    return win * reveal;
}

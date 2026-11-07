float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    float seed = umbriel_random_seed.x * 100.0;
    float rp = 1.0 - p;

    float num_layers = 10.0;
    float pixel_layer = floor(hash(floor(uv * umbriel_size.xy) + seed) * num_layers);

    vec4 result = vec4(0.0);
    vec2 target = vec2(1.0, 0.0);

    for (int i = 0; i < 10; i++) {
        float layer = float(i);
        float layer_delay = layer * 0.06;
        float layer_p = clamp((rp - layer_delay) / (1.0 - layer_delay * 0.5), 0.0, 1.0);

        float t = layer_p * layer_p;

        float layer_alpha = 1.0 - smoothstep(0.3, 0.85, layer_p);

        float lh = hash(vec2(layer + 0.5, seed));
        vec2 layer_target = target + vec2(-0.08 + lh * 0.16, -0.04 + lh * 0.08);

        float converge = t * 0.92;
        vec2 sample_uv = (uv - layer_target * converge) / (1.0 - converge);

        vec4 color = umbriel_sample(sample_uv);

        float belongs = step(abs(pixel_layer - layer), 0.5);
        result += color * belongs * layer_alpha;
    }

    float initial_form = smoothstep(0.0, 0.05, rp);
    result.a *= mix(1.0, 0.0, initial_form);
    vec4 base_color = umbriel_sample(uv);
    float base_alpha = 1.0 - smoothstep(0.0, 0.1, rp);

    return base_color * base_alpha + result * (1.0 - base_alpha);
}

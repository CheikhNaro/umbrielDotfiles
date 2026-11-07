// Ported from skwd-wall crosshatch transition

float crosshatch_rand(vec2 co) {
    return fract(sin(dot(co.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

vec4 animation(vec2 uv) {
    float p = umbriel_clamped_progress;
    vec4 win = umbriel_sample(uv);

    vec2 center = vec2(0.5);
    float threshold = 3.0;
    float fadeEdge = 0.1;
    float dist = distance(center, uv) / threshold;
    float r = p - min(crosshatch_rand(vec2(uv.y, 0.0)), crosshatch_rand(vec2(0.0, uv.x)));
    float reveal = mix(0.0, mix(step(dist, r), 1.0, smoothstep(1.0 - fadeEdge, 1.0, p)), smoothstep(0.0, fadeEdge, p));

    return win * reveal;
}

// Ported from skwd-wall colour-distance transition

vec4 animation(vec2 uv) {
    float p = 1.0 - umbriel_clamped_progress;
    float power = 5.0;

    vec4 win = umbriel_sample(uv);

    float colorMag = length(win.rgb);
    float m = step(colorMag, p);
    float reveal = mix(m, 1.0, pow(p, power));

    return win * reveal;
}

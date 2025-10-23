//
// sh_vign_grain.fsh
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_Time;
uniform float u_VigStrength;   // 0–1
uniform float u_GrainStrength; // 0–~0.2
uniform vec2  u_Resolution;    // base surface res (e.g., 640x360)

float hash(vec2 p) {
    // tiny noise; screen-space grain that animates
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void main() {
    vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);

    // Vignette
    vec2 uv = v_vTexcoord * 2.0 - 1.0;
    float r = dot(uv, uv);           // 0 center → ~2 corners
    float vig = 1.0 - smoothstep(0.6, 1.2, r);
    col.rgb *= mix(1.0, vig, u_VigStrength);

    // Grain (per-pixel, time-varying)
    vec2 pix = v_vTexcoord * u_Resolution + u_Time * 60.0;
    float n = hash(pix);
    col.rgb += (n - 0.5) * u_GrainStrength;

    gl_FragColor = col * v_vColour;
}

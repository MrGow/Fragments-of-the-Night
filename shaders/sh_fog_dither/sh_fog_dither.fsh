//
// sh_fog_dither.fsh
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform float u_Time;
uniform vec4  u_Params; // yStart, yEnd, strength, pad

float noise(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

void main() {
    vec4 col = texture2D(gm_BaseTexture, v_vTexcoord);
    float yStart = u_Params.x;
    float yEnd   = u_Params.y;
    float str    = u_Params.z;

    // Convert v_vTexcoord.y (0..1) to screen Y (0..surfaceH)
    // We don’t know surfaceH here; approximate with texcoord:
    float y = v_vTexcoord.y; // 0 top, 1 bottom

    float t = smoothstep(yStart/360.0, yEnd/360.0, y); // if surfaceH=360
    float n = noise(v_vTexcoord * 800.0 + u_Time * 0.2) * 0.05; // tiny dithering
    col.rgb = mix(col.rgb, col.rgb * (1.0 - 0.5 * (t + n)), str * t);

    gl_FragColor = col * v_vColour;
}

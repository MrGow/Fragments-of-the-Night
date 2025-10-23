//
// sh_lut.fsh
//
varying vec2 v_vTexcoord;
varying vec4 v_vColour;

uniform sampler2D u_LUT;   // bound at texture unit 1
uniform float u_LUTRows;   // e.g., 16.0
uniform float u_Strength;  // 0–1

vec3 sampleLUT(vec3 rgb) {
    // Assumes a 256x(16*16) or 512x(16*16) strip LUT with 16 rows of 16 tiles.
    // This is a compact approximation—good enough for stylized grading.
    float rowF = floor(rgb.b * (u_LUTRows - 1.0));
    float rowV = (rowF + 0.5) / u_LUTRows;

    // x maps r,g into 0..1 horizontally; pack 16 tiles across
    float tile = floor(rgb.r * 15.0);
    float xIn  = fract(rgb.r * 15.0);
    float gx   = (tile + xIn) / 16.0;

    // y packs green within the row
    float gy   = (rgb.g) / u_LUTRows + rowV / u_LUTRows;

    vec3 graded = texture2D(u_LUT, vec2(gx, gy)).rgb;
    return graded;
}

void main() {
    vec4 base = texture2D(gm_BaseTexture, v_vTexcoord);
    vec3 graded = sampleLUT(base.rgb);
    base.rgb = mix(base.rgb, graded, clamp(u_Strength, 0.0, 1.0));
    gl_FragColor = base * v_vColour;
}

varying vec2 v_vTexcoord;
varying vec4 v_vColour;
uniform vec2  u_center;
uniform float u_amount;

void main() {
    vec2 uv = v_vTexcoord;
    vec2 d  = uv - u_center;

    float eps = 1e-5;
    float r   = length(d) + eps;

    float fall = 1.0 - smoothstep(0.0, 1.0, r);
    float k    = u_amount * fall;

    vec2 n = d / r;
    uv += vec2(-n.y, n.x) * k;

    uv = clamp(uv, vec2(0.002), vec2(0.998)); // critical!

    gl_FragColor = texture2D(gm_BaseTexture, uv) * v_vColour;
}


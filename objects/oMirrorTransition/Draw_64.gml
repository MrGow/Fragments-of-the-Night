/// oMirrorTransition — Draw GUI (FULL EVENT)

// -----------------------------------------------------------------------------
// Setup
// -----------------------------------------------------------------------------
var gw = display_get_gui_width();
var gh = display_get_gui_height();

// Prefer the processed frame from oPostFX; fall back to application_surface.
var surf = (global.postfx_ready && surface_exists(global.postfx_surface))
    ? global.postfx_surface
    : application_surface;

// Local helpers
function __smoothstep(a, b, x) {
    if (a == b) return (x >= b) ? 1 : 0;
    var t = clamp((x - a) / (b - a), 0, 1);
    return t * t * (3 - 2 * t);
}

// Bail early if idle
if (phase == Phase.Idle) exit;

// -----------------------------------------------------------------------------
// Hard veil during MASK/HOLD (hide room load/snap)
// -----------------------------------------------------------------------------
if (phase == Phase.MaskUntilStable || phase == Phase.Hold) {
    draw_set_color(c_black);
    draw_set_alpha(clamp(hold_alpha, 0, 1));
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1);
    exit;
}

// -----------------------------------------------------------------------------
// Progress t (0..1). When phase==Out we go 0→1; when In we go 1→0.
// -----------------------------------------------------------------------------
var denom_p = max(1, abs(img_end - img_start));
var p = (phase == Phase.Out)
    ? clamp((image_index - img_start) / denom_p, 0, 1)
    : clamp((img_start - image_index) / denom_p, 0, 1);

// -----------------------------------------------------------------------------
// Refraction overlay of the *current frame* (processed by oPostFX if available)
// -----------------------------------------------------------------------------
if (surface_exists(surf)) {
    var peak   = (phase == Phase.Out) ? __smoothstep(0.20, 0.92, p) : __smoothstep(0.12, 0.85, p);
    var amount = 0.018 * peak * (0.75 + 0.25 * sin(current_time * 0.015));

    gpu_set_texrepeat(false);
    gpu_set_texfilter(false);

    var sh = sh_refraction_simple; // your refraction shader resource
    if (sh != -1) {
        shader_set(sh);
        var u_c = shader_get_uniform(sh, "u_center");
        var u_a = shader_get_uniform(sh, "u_amount");
        if (u_c != -1) shader_set_uniform_f(u_c, 0.5, 0.5);
        if (u_a != -1) shader_set_uniform_f(u_a, amount);

        // If you like the 1px inset “frame” look, keep 1/1/gw-2/gh-2; else use full.
        draw_surface_stretched(surf, 1, 1, gw - 2, gh - 2);

        shader_reset();
    } else {
        draw_surface_stretched(surf, 0, 0, gw, gh);
    }

    gpu_set_texfilter(true);
    gpu_set_texrepeat(false);
}

// -----------------------------------------------------------------------------
// Tiny local shake for shards
// -----------------------------------------------------------------------------
var sx_off = 0, sy_off = 0;
if (shake_timer > 0) {
    var k = clamp(shake_timer / max(1, round(room_speed * 0.10)), 0, 1);
    sx_off = irandom_range(-1, 1) * (1 + floor(2 * k));
    sy_off = irandom_range(-1, 1) * (1 + floor(2 * k));
    shake_timer--;
}

// -----------------------------------------------------------------------------
// Shard sprite (scaled to fill GUI)
// -----------------------------------------------------------------------------
var sw  = sprite_get_width(sprite_index);
var shh = sprite_get_height(sprite_index);
var sx  = gw / max(1, sw);
var sy  = gh / max(1, shh);
var s   = max(sx, sy);
var dw  = sw * s, dh = shh * s;
var dx  = (gw - dw) * 0.5 + sx_off;
var dy  = (gh - dh) * 0.5 + sy_off;

var subimg = floor(image_index);

draw_sprite_ext(sprite_index, subimg, dx, dy, s, s, 0, c_white, 1);

// -----------------------------------------------------------------------------
// Color/glow passes
// -----------------------------------------------------------------------------
var col_core  = make_color_hsv(190, 70, 255);
var col_glint = make_color_hsv( 40, 30, 255);

gpu_set_blendmode(bm_add);
draw_sprite_ext(sprite_index, subimg, dx, dy, s * 1.035, s * 1.035, 0, col_core, 0.22);

gpu_set_blendmode(bm_normal);
draw_sprite_ext(sprite_index, subimg, dx, dy, s, s, 0, merge_color(c_white, col_core, 0.35), 0.25);

gpu_set_blendmode(bm_add);
draw_sprite_ext(sprite_index, subimg, dx, dy, s * 1.01, s * 1.01, 0, col_glint, 0.15 * p);
gpu_set_blendmode(bm_normal);

// -----------------------------------------------------------------------------
// Optional sparkles
// -----------------------------------------------------------------------------
var sprSpark = asset_get_index("sprSpark");
if (sprSpark != -1) {
    var N = round(8 * p);
    if (N > 0) {
        gpu_set_blendmode(bm_add);
        var rad_base = (gw + gh) * 0.03;
        for (var i = 0; i < N; i++) {
            var ang = (i / max(1, N)) * 6.28318;
            var rad = rad_base * (0.6 + 0.8 * p);
            var spx = gw * 0.5 + cos(ang) * rad + sx_off;
            var spy = gh * 0.5 + sin(ang) * rad + sy_off;
            draw_sprite_ext(sprSpark, 0, spx, spy, 1, 1, 0, c_white, 0.35 * p);
        }
        gpu_set_blendmode(bm_normal);
    }
}

// -----------------------------------------------------------------------------
// Micro flash near completion
// -----------------------------------------------------------------------------
var flash = __smoothstep(0.80, 1.00, p);
if (flash > 0) {
    draw_set_alpha(0.12 * flash);
    draw_set_color(c_white);
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1);
}

// -----------------------------------------------------------------------------
// Edge vignette bars (keeps your original look)
// -----------------------------------------------------------------------------
var vig = 0.15;
draw_set_alpha(vig);
draw_set_color(c_black);
var bar = round(gh * 0.10);
draw_rectangle(0, 0, gw, bar, false);
draw_rectangle(0, gh - bar, gw, gh, false);
draw_set_alpha(1);

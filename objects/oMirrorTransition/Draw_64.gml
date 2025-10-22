/// oMirrorTransition - Draw GUI
var gw = display_get_gui_width();
var gh = display_get_gui_height();

if (phase == Phase.Idle) exit;

// 1) During HOLD, draw a topmost blackout veil and bail
if (phase == Phase.Hold) {
    draw_set_color(c_black);
    draw_set_alpha(clamp(hold_alpha, 0, 1));
    draw_rectangle(0, 0, gw, gh, false);
    draw_set_alpha(1);
    exit;
}

// 2) REFRACTION OVERLAY (under shards)
// By Draw GUI time, application_surface contains the *fully rendered* current room.
if (surface_exists(application_surface)) {
    // Progress for strength: 0→1 (OUT), 1→0 (IN)
    var p = 0;
    if (phase == Phase.Out) {
        var denom = max(1, abs(img_end - img_start));
        p = clamp((image_index - img_start) / denom, 0, 1);
    } else if (phase == Phase.In) {
        var denom2 = max(1, abs(img_start - img_end));
        p = clamp((img_start - image_index) / denom2, 0, 1);
    }

    var amount = 0.016 * p;

    gpu_set_texrepeat(false);
    gpu_set_texfilter(false);

    var sh = sh_refraction_simple;
    if (sh != -1) {
        shader_set(sh);
        var u_c = shader_get_uniform(sh, "u_center");
        var u_a = shader_get_uniform(sh, "u_amount");
        if (u_c != -1) shader_set_uniform_f(u_c, 0.5, 0.5);
        if (u_a != -1) shader_set_uniform_f(u_a, amount);

        // Use GUI size so it covers the whole screen in GUI space
        draw_surface_stretched(application_surface, 1, 1, gw - 2, gh - 2);

        shader_reset();
    } else {
        draw_surface_stretched(application_surface, 0, 0, gw, gh);
    }

    gpu_set_texfilter(true);
    gpu_set_texrepeat(false);
}

// 3) SHARDS SPRITE on top (scaled to cover)
var sw = sprite_get_width(sprite_index);
var sh = sprite_get_height(sprite_index);
var sx = gw / sw, sy = gh / sh, s = max(sx, sy);
var dw = sw * s, dh = sh * s;
var dx = (gw - dw) * 0.5;
var dy = (gh - dh) * 0.5;

draw_sprite_ext(sprite_index, floor(image_index), dx, dy, s, s, 0, c_white, 1);

// 4) Soft vignette/letterbox on top
var vig = 0.15;
draw_set_alpha(vig);
draw_set_color(c_black);
var bar = round(gh * 0.10);
draw_rectangle(0, 0, gw, bar, false);
draw_rectangle(0, gh - bar, gw, gh, false);
draw_set_alpha(1);

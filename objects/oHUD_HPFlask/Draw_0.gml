/// oHUD_HPFlask — Draw  (compact, top-left; dynamic fullscreen scaling)

// ---------- Dynamic HUD scale based on integer app-surface scale ----------
// Prefer the scaler published by oGame.Draw End (if present)
var cam = view_camera[0];
if (cam == -1) exit;

var app_s = 1;
if (variable_global_exists("_appsurf_scale")) {
    app_s = max(1, global._appsurf_scale);
} else {
    // Fallback: derive from current display vs app-surface view
    var vw = camera_get_view_width(cam);
    var vh = camera_get_view_height(cam);
    app_s = max(1, floor(min(display_get_width() / vw, display_get_height() / vh)));
}

// Tiered HUD scale (smaller at higher fullscreen scales)
var HUD_S;
switch (app_s) {
    case 1:  HUD_S = 0.70; break; // windowed ~640x360
    case 2:  HUD_S = 0.80; break; // ~1280x720
    case 3:  HUD_S = 0.72; break; // 1080p fullscreen — slightly smaller than windowed
    case 4:  HUD_S = 0.60; break; // 1440p
    default: HUD_S = 0.55; break; // 4K+
}

// ---------- Anchor to camera top-left, then apply HUD scale ----------
var vx = camera_get_view_x(cam);
var vy = camera_get_view_y(cam);

var mw = matrix_get(matrix_world);
var M  = matrix_build(vx, vy, 0,   0,0,0,   HUD_S, HUD_S, 1);
matrix_set(matrix_world, matrix_multiply(mw, M));

// -------------- draw the HUD at (base_x, base_y) --------------
base_x = round(base_x);
base_y = round(base_y);

var gx = base_x;
var gy = base_y;

// ===== Skull (HP scale) =====
var spr_skull = (skull_alert_t > 0) ? spr_skull_alert : spr_skull_idle;
draw_sprite_ext(spr_skull, 0, gx, gy + skull_y_nudge, ui_scale_hp, ui_scale_hp, 0, c_white, 1);

// ===== HP row baseline (HP scale) =====
var hp_x = round(gx + skull_w + 4);
var hp_y = round(gy + hp_y_offset);

// ===== Vine behind moons (HP scale) =====
var step = (moon_w + moon_gap_px);
var moon_row_x = hp_x - antler_bridge_px + (lead_conn_count * step);

var vine_start = moon_row_x;
var vine_end   = moon_row_x + (max_hp_cache * step);

var vxx = vine_start;
for (var i = 0; i < max_hp_cache; i++) {
    draw_sprite_ext(spr_connector, 0, round(vxx), hp_y, ui_scale_hp, ui_scale_hp, 0, c_white, 1);
    vxx += step;
}
draw_sprite_ext(spr_connector_end, 0, round(vine_end), hp_y, ui_scale_hp, ui_scale_hp, 0, c_white, 1);

// ===== Moons (HP scale, on top of vine) =====
var last = sprite_get_number(spr_moon_fill_strip) - 1;

for (var i2 = 0; i2 < max_hp_cache; i2++) {
    var mx = round(moon_row_x + i2 * step);

    if (moon_state[i2] == 1) {
        draw_sprite_ext(spr_moon_full, 0, mx, hp_y, ui_scale_hp, ui_scale_hp, 0, c_white, 1);
    } else if (moon_state[i2] == 0) {
        draw_sprite_ext(spr_moon_empty, 0, mx, hp_y, ui_scale_hp, ui_scale_hp, 0, c_white, 1);
    }

    if (moon_state[i2] == 2) {
        var subimg = clamp(floor(moon_frame[i2]), 0, last);
        draw_sprite_ext(spr_moon_fill_strip, subimg, mx, hp_y, ui_scale_hp, ui_scale_hp, 0, c_white, 1);
    }
}

// ===== Chalice row (CHALICE scale, under moons) =====
var chal_alpha = 1.0;
if (variable_global_exists("flask_stock") && global.flask_stock <= 0) chal_alpha = 0.6;

var chal_x = round(hp_x);
var chal_y = round(hp_y + moon_h + row_gap_px);

// Drink anim follows timer
var drink_t = (variable_global_exists("_drinking_timer") ? global._drinking_timer : 0);

if (drink_t > 0) {
    var peak  = max(1, drink_timer_max);
    var total = max(1, sprite_get_number(spr_flask_use_strip));
    var p     = 1 - (drink_t / peak);
    var sub   = clamp(floor(p * (total - 1)), 0, total - 1);
    draw_sprite_ext(spr_flask_use_strip, sub, chal_x, chal_y, ui_scale_chalice, ui_scale_chalice, 0, c_white, chal_alpha);
} else {
    draw_sprite_ext(spr_flask_idle, 0, chal_x, chal_y, ui_scale_chalice, ui_scale_chalice, 0, c_white, chal_alpha);
}

// ===== Digits (CHALICE scale) =====
var stock = (variable_global_exists("flask_stock") ? max(0, global.flask_stock) : 0);
var num   = string(stock);
var len   = string_length(num);

var digits_x = round(chal_x + chal_w + 2);
for (var di = 1; di <= len; di++) {
    var ch = string_char_at(num, di);
    var d  = ord(ch) - ord("0");
    if (d >= 0 && d <= 9) {
        var sxp = round(digits_x + ((di - 1) * (digit_w + digit_gap)));
        draw_sprite_ext(spr_digits, d, sxp, chal_y, ui_scale_chalice, ui_scale_chalice, 0, c_white, chal_alpha);
    }
}

// ---------- Restore matrix ----------
matrix_set(matrix_world, mw);

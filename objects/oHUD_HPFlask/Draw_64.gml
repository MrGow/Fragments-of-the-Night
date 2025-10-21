/// oHUD_HPFlask — Draw GUI

// Row 1: Skull + continuous vine + Moons
// Row 2: Chalice + digits

var gx = base_x;
var gy = base_y;

// ===== Skull =====
var spr_skull = (skull_alert_t > 0) ? spr_skull_alert : spr_skull_idle;
draw_sprite_ext(spr_skull, 0, gx, gy + skull_y_nudge, ui_scale, ui_scale, 0, c_white, 1);

// HP row baseline
var hp_x = gx + skull_w + 6;
var hp_y = gy + hp_y_offset;

// ===== Vine (behind moons), phase-locked to moon spacing =====
var step = (moon_w + moon_gap_px);
var moon_row_x = hp_x + (lead_conn_count * step);
var vine_start = moon_row_x;
var vine_end   = moon_row_x + (max_hp_cache * step);

var vx = vine_start;
for (var i = 0; i < max_hp_cache; i++) {
    draw_sprite_ext(spr_connector, 0, vx, hp_y, ui_scale, ui_scale, 0, c_white, 1);
    vx += step;
}
draw_sprite_ext(spr_connector_end, 0, vine_end, hp_y, ui_scale, ui_scale, 0, c_white, 1);

// ===== Moons (on top of the vine) =====
var last = sprite_get_number(spr_moon_fill_strip) - 1;

for (var i2 = 0; i2 < max_hp_cache; i2++) {
    var mx = moon_row_x + i2 * step;

    if (moon_state[i2] == 1) {
        draw_sprite_ext(spr_moon_full, 0, mx, hp_y, ui_scale, ui_scale, 0, c_white, 1);
    } else if (moon_state[i2] == 0) {
        draw_sprite_ext(spr_moon_empty, 0, mx, hp_y, ui_scale, ui_scale, 0, c_white, 1);
    }

    if (moon_state[i2] == 2) {
        var subimg = clamp(floor(moon_frame[i2]), 0, last);
        draw_sprite_ext(spr_moon_fill_strip, subimg, mx, hp_y, ui_scale, ui_scale, 0, c_white, 1);
    }
}

// ===== Chalice row (under moons, left-aligned) =====
var chal_alpha = 1.0;
if (variable_global_exists("flask_stock") && global.flask_stock <= 0) chal_alpha = 0.6;

var chal_x = hp_x;
var chal_y = hp_y + moon_h + row_gap_px;

// ---- DRINK-ANIM: follow global._drinking_timer exactly ----
var drink_t = (variable_global_exists("_drinking_timer") ? global._drinking_timer : 0);

if (drink_t > 0) {
    var peak  = max(1, drink_timer_max); // << always defined now
    var total = max(1, sprite_get_number(spr_flask_use_strip));
    var p     = 1 - (drink_t / peak);                // 0 → 1 over the sip
    var sub   = clamp(floor(p * (total - 1)), 0, total - 1);
    draw_sprite_ext(spr_flask_use_strip, sub, chal_x, chal_y, ui_scale, ui_scale, 0, c_white, chal_alpha);
} else {
    draw_sprite_ext(spr_flask_idle, 0, chal_x, chal_y, ui_scale, ui_scale, 0, c_white, chal_alpha);
}

// Digits
var stock = (variable_global_exists("flask_stock") ? max(0, global.flask_stock) : 0);
var num   = string(stock);
var len   = string_length(num);

var digits_x = chal_x + chal_w + 2;
for (var i = 1; i <= len; i++) {
    var ch = string_char_at(num, i);
    var d  = ord(ch) - ord("0");
    if (d >= 0 && d <= 9) {
        var sx = digits_x + ((i - 1) * (digit_w + digit_gap));
        draw_sprite_ext(spr_digits, d, sx, chal_y, ui_scale, ui_scale, 0, c_white, chal_alpha);
    }
}

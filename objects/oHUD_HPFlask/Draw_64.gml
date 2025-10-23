/// oHUD_HPFlask — Draw GUI

// Snap anchors to integers to keep things crisp
base_x = round(base_x);
base_y = round(base_y);

var gx = base_x;
var gy = base_y;

// ===== Skull (HP scale) =====
var spr_skull = (skull_alert_t > 0) ? spr_skull_alert : spr_skull_idle;
draw_sprite_ext(spr_skull, 0, gx, gy + skull_y_nudge, ui_scale_hp, ui_scale_hp, 0, c_white, 1);

// HP row baseline (HP scale)
var hp_x = round(gx + skull_w + 6);
var hp_y = round(gy + hp_y_offset);

// ===== Vine behind moons (HP scale) =====
var step = (moon_w + moon_gap_px);

var moon_row_x = hp_x + (lead_conn_count * step);
var vine_start = moon_row_x;
var vine_end   = moon_row_x + (max_hp_cache * step);

var vx = vine_start;
for (var i = 0; i < max_hp_cache; i++) {
    draw_sprite_ext(spr_connector, 0, round(vx), hp_y, ui_scale_hp, ui_scale_hp, 0, c_white, 1);
    vx += step;
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

// Align chalice left with first moon; drop under the HP row with row_gap_px.
// (We compute positions in HP units, then draw with chalice scale.)
var chal_x = round(hp_x);
var chal_y = round(hp_y + moon_h + row_gap_px);

// Drink anim follows timer (works as before)
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
for (var i = 1; i <= len; i++) {
    var ch = string_char_at(num, i);
    var d  = ord(ch) - ord("0");
    if (d >= 0 && d <= 9) {
        var sx = round(digits_x + ((i - 1) * (digit_w + digit_gap)));
        draw_sprite_ext(spr_digits, d, sx, chal_y, ui_scale_chalice, ui_scale_chalice, 0, c_white, chal_alpha);
    }
}

/// oHUD_HPFlask — Create
persistent = true; // keep HUD across rooms

// ====== CONFIG ======
ui_scale        = 1.0;
margin_x        = 16;
margin_y        = 36;

moon_gap_px     = 3;
anim_speed      = 0.6;
skull_alert_ms  = 10;
heal_anim_ms    = 14;

lead_conn_count = 0;      // moons start immediately
row_gap_px      = 6;
hp_y_offset     = 12;
skull_y_nudge   = 64;

// Vine look
connector_flipped               = false; // your art is correct orientation
connector_step_locked_to_moons  = true;  // phase-lock vine beats to moon spacing

// ====== SPRITES ======
spr_moon_full        = sprite_moon_full;
spr_moon_empty       = sprite_moon_empty;
spr_moon_fill_strip  = sprite_moon_fill_strip;

spr_connector        = sprite_hp_connector;
spr_connector_end    = sprite_hp_connector_end;

spr_skull_idle       = sprite_skull_idle;
spr_skull_alert      = sprite_skull_alert;

spr_flask_idle       = sprite_flask_idle;
spr_flask_use_strip  = sprite_flask_use_strip;

spr_digits           = sprite_digit_strip;

// ====== DERIVED LAYOUT ======
moon_w   = sprite_get_width(spr_moon_full)  * ui_scale;
moon_h   = sprite_get_height(spr_moon_full) * ui_scale;

chal_w   = sprite_get_width(spr_flask_idle) * ui_scale;
chal_h   = sprite_get_height(spr_flask_idle)* ui_scale;

skull_w  = sprite_get_width(spr_skull_idle) * ui_scale;
skull_h  = sprite_get_height(spr_skull_idle)* ui_scale;

conn_w_raw  = sprite_get_width(spr_connector)      * ui_scale;
end_w_raw   = sprite_get_width(spr_connector_end)  * ui_scale;

digit_w  = sprite_get_width(spr_digits)  * ui_scale;
digit_h  = sprite_get_height(spr_digits) * ui_scale;
digit_gap= 0;

base_x = margin_x;
base_y = margin_y;

// ====== RUNTIME STATE ======
target_hp     = (variable_global_exists("hp") ? global.hp : 1);
display_hp    = target_hp;
max_hp_cache  = (variable_global_exists("max_hp") ? global.max_hp : 1);

skull_alert_t = 0;
chal_anim_t   = 0;

var cap = max(1, max_hp_cache);
moon_state  = array_create(cap, 0);
moon_frame  = array_create(cap, 0);
moon_dir    = array_create(cap, 0);
active_anim_index = -1;

var last = sprite_get_number(spr_moon_fill_strip) - 1;
for (var i = 0; i < max_hp_cache; i++) {
    if (i < display_hp) {
        moon_state[i] = 1;
        moon_frame[i] = 0;
        moon_dir[i]   = 0;
    } else {
        moon_state[i] = 0;
        moon_frame[i] = last;
        moon_dir[i]   = 0;
    }
}

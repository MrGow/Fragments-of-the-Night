/// oHUD_HPFlask — Create
persistent = true; // keep HUD across rooms

// ====== CONFIG ======
// Separate scales: HP bar can stay crisp at 1.0; chalice+digits can be smaller.
ui_scale_hp      = 1.0;   // skull, vine, moons
ui_scale_chalice = 0.80;   // chalice + number (try 0.75/0.5/1.0)

// TIP: Non-integer scales may blur pixel art. If it looks soft, use 1.0 or 0.5.

margin_x        = 100;
margin_y        = 120;

moon_gap_px     = 3;
anim_speed      = 0.6;
skull_alert_ms  = 10;

lead_conn_count = 0;      // moons start immediately
row_gap_px      = 6;      // vertical gap between HP row and chalice row
hp_y_offset     = 4;      // slight vertical nudge for the HP row
skull_y_nudge   = 65;     // bring skull down to meet the vine

// Vine look
connector_flipped               = false;
connector_step_locked_to_moons  = true;

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

// ====== DERIVED LAYOUT (per-scale) ======
// HP bar pieces measured with ui_scale_hp
moon_w   = sprite_get_width(spr_moon_full)  * ui_scale_hp;
moon_h   = sprite_get_height(spr_moon_full) * ui_scale_hp;

skull_w  = sprite_get_width(spr_skull_idle) * ui_scale_hp;
skull_h  = sprite_get_height(spr_skull_idle)* ui_scale_hp;

conn_w_raw  = sprite_get_width(spr_connector)      * ui_scale_hp;
end_w_raw   = sprite_get_width(spr_connector_end)  * ui_scale_hp;

// Chalice/digits measured with ui_scale_chalice
chal_w   = sprite_get_width(spr_flask_idle) * ui_scale_chalice;
chal_h   = sprite_get_height(spr_flask_idle)* ui_scale_chalice;

digit_w  = sprite_get_width(spr_digits)  * ui_scale_chalice;
digit_h  = sprite_get_height(spr_digits) * ui_scale_chalice;
digit_gap= 0;

base_x = margin_x;
base_y = margin_y;

// ====== RUNTIME STATE ======
target_hp     = (variable_global_exists("hp") ? global.hp : 1);
display_hp    = target_hp;
max_hp_cache  = (variable_global_exists("max_hp") ? global.max_hp : 1);

skull_alert_t = 0;

// Drink timing book-keeping
prev_drink_timer = (variable_global_exists("_drinking_timer") ? global._drinking_timer : 0);
drink_timer_max  = (variable_global_exists("_drink_lockout") ? max(1, global._drink_lockout)
                                                             : max(1, sprite_get_number(spr_flask_use_strip)));

// Per-moon arrays
var cap = max(1, max_hp_cache);
moon_state  = array_create(cap, 0);
moon_frame  = array_create(cap, 0);
moon_dir    = array_create(cap, 0);
active_anim_index = -1;

var last = sprite_get_number(spr_moon_fill_strip) - 1;
for (var i = 0; i < max_hp_cache; i++) {
    if (i < display_hp) { moon_state[i] = 1; moon_frame[i] = 0; moon_dir[i] = 0; }
    else { moon_state[i] = 0; moon_frame[i] = last; moon_dir[i] = 0; }
}


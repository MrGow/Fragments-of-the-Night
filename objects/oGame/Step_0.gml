/// oGame — Step  (pause toggle + quick quit)

// Toggle fullscreen
if (keyboard_check_pressed(vk_f11)) {
    window_set_fullscreen(!window_get_fullscreen());
}

// Quick quit (dev): Shift + Esc
if (keyboard_check(vk_shift) && keyboard_check_pressed(vk_escape)) { game_end(); exit; }

// Gamepad Start detection (up to 4 pads)
var gp_start_pressed = false;
for (var i = 0; i < 4; i++) {
    if (!gamepad_is_connected(i)) continue;
    if (gamepad_button_check_pressed(i, gp_start)) gp_start_pressed = true;
}

/// oGame — Step (excerpt: pause toggle)

// Gamepad Start detection (up to 4 pads)
var gp_start_pressed = false;
for (var i = 0; i < 4; i++) {
    if (!gamepad_is_connected(i)) continue;
    if (gamepad_button_check_pressed(i, gp_start)) gp_start_pressed = true;
}

// Debounced pause toggle (Esc or Start)
var pressed = keyboard_check_pressed(vk_escape) || gp_start_pressed;
if (pressed && can_toggle) {
    if (global.paused) script_close_pause(); else script_open_pause();
    can_toggle = false;
}
if (!keyboard_check(vk_escape)) can_toggle = true;

// DEV: force-spawn a slash with 'K' to bypass input gates (remove later)
if (keyboard_check_pressed(ord("K"))) {
    var pl = instance_exists(oPlayer) ? instance_find(oPlayer, 0) : noone;
    if (pl != noone) {
        var forward = (pl.image_xscale == 0) ? 1 : sign(pl.image_xscale);
        var hb = instance_create_layer(pl.x + forward * 18, pl.y, layer_get_id("Actors"), oPlayerSlash);
        hb.owner = pl;
        hb.direction_sign = forward;
        hb.damage = 1;
        show_debug_message("[DEV] Forced slash spawn");
    }
}

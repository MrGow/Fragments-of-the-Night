/// oGame — Step

// Toggle fullscreen
if (keyboard_check_pressed(vk_f11)) {
    window_set_fullscreen(!window_get_fullscreen());
}

// Gamepad Start states (any of up to 4 pads)
var gp_start_pressed = false;
var gp_start_down    = false;
for (var i = 0; i < 4; i++) {
    if (!gamepad_is_connected(i)) continue;
    if (gamepad_button_check_pressed(i, gp_start)) gp_start_pressed = true;
    if (gamepad_button_check(i, gp_start))          gp_start_down    = true;
}

// Quick quit (dev): Shift + Esc
if (keyboard_check(vk_shift) && keyboard_check_pressed(vk_escape)) { game_end(); exit; }

// Debounced pause toggle (Esc or Start)
var pressed = keyboard_check_pressed(vk_escape) || gp_start_pressed;
if (pressed && can_toggle) {
    if (global.paused) close_pause(); else open_pause();
    can_toggle = false;
}
if (!keyboard_check(vk_escape) && !gp_start_down) can_toggle = true;

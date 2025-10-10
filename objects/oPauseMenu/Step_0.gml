if (!variable_global_exists("paused") || !global.paused) { instance_destroy(); exit; }

if (input_cd > 0) input_cd--;

// Keyboard
var move_up   = keyboard_check_pressed(vk_up);
var move_down = keyboard_check_pressed(vk_down);
var confirm   = keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space);

// Gamepad
for (var i = 0; i < 4; i++) {
    if (!gamepad_is_connected(i)) continue;
    move_up   = move_up   || gamepad_button_check_pressed(i, gp_padu);
    move_down = move_down || gamepad_button_check_pressed(i, gp_padd);
    confirm   = confirm   || gamepad_button_check_pressed(i, gp_face1); // A/Cross
}

// Nav
if (input_cd == 0) {
    if (move_up)   { sel = (sel - 1 + array_length(menu_items)) mod array_length(menu_items); input_cd = input_cd_max; }
    if (move_down) { sel = (sel + 1) mod array_length(menu_items); input_cd = input_cd_max; }
}

// Confirm
if (confirm) {
    switch (sel) {
        case 0: with (oGame) close_pause(); break;                                 // Resume
        case 1: /* open settings later */ break;                                   // Settings
        case 2: instance_activate_all(); audio_resume_all(); global.paused = false; room_goto(rTitle); break;
        case 3: instance_activate_all(); audio_resume_all(); global.paused = false; game_end(); break;
    }
}



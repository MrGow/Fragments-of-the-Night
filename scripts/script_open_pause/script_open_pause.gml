function script_open_pause() {
    // Already paused? do nothing
    if (global.paused) return;

    // Freeze world but keep the caller active
    instance_deactivate_all(true);

    // Create pause menu AFTER deactivation so it stays active
    if (object_exists(oPauseMenu)) {
        global.pause_menu_id = instance_create_depth(0, 0, -100000, oPauseMenu);
    } else {
        global.pause_menu_id = noone;
    }

    audio_pause_all();

    // Gate input while paused
    if (!is_undefined(global.input)) {
        global.input.input_enabled  = false;
        global.input.ui_captured    = true;
        global.input.player_locked  = true;
        // clear one-frame pulses so we don't "eat" a press on resume
        global.input.jump_pressed   = false;
        global.input.attack_pressed = false;
    }

    global.paused = true;
}


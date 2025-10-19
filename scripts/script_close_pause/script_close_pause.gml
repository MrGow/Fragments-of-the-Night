function script_close_pause() {
    // Not paused? do nothing
    if (!global.paused) return;

    // Destroy pause menu if it exists
    if (instance_exists(global.pause_menu_id)) with (global.pause_menu_id) instance_destroy();
    global.pause_menu_id = noone;

    audio_resume_all();
    instance_activate_all();

    // Fully restore input gates
    if (!is_undefined(global.input)) {
        global.input.input_enabled  = true;
        global.input.ui_captured    = false;
        global.input.player_locked  = false;
        global.input.jump_pressed   = false;
        global.input.attack_pressed = false;
    }

    global.paused = false;
}

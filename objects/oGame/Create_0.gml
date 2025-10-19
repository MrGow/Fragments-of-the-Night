/// oGame — Create

// Make sure the application surface is on (some projects turn it off)
application_surface_enable(true);

// Init pause state & debounce
global.paused = false;
can_toggle    = true;

// Ensure portal flag exists so Room Start can safely read it
if (!variable_global_exists("pending_unlock_input")) {
    global.pending_unlock_input = false;
}

// (Nice-to-have) init a handle for the pause menu
if (!variable_global_exists("pause_menu_id")) {
    global.pause_menu_id = noone;
}

// Pause helpers — order matters
open_pause = function() {
    if (global.paused) return;

    // Freeze world but keep THIS instance active
    instance_deactivate_all(true);

    // Create menu AFTER deactivation so it remains active
    if (!instance_exists(global.pause_menu_id)) {
        global.pause_menu_id = instance_create_depth(0, 0, -100000, oPauseMenu);
    }

    audio_pause_all();

    // ALSO set global input gates (UI owns input while paused)
    if (!is_undefined(global.input)) {
        global.input.input_enabled  = false;
        global.input.ui_captured    = true;
        global.input.player_locked  = true;
        global.input.jump_pressed   = false; // clear pulses
        global.input.attack_pressed = false;
    }

    global.paused = true;
};

close_pause = function() {
    if (!global.paused) return;

    if (instance_exists(global.pause_menu_id)) with (global.pause_menu_id) instance_destroy();
    global.pause_menu_id = noone;

    audio_resume_all();
    instance_activate_all();

    // Symmetric: fully unlock input on resume
    if (!is_undefined(global.input)) {
        global.input.input_enabled  = true;
        global.input.ui_captured    = false;
        global.input.player_locked  = false;
        global.input.jump_pressed   = false;
        global.input.attack_pressed = false;
    }

    global.paused = false;
};



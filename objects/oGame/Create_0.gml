// Globals
if (!variable_global_exists("paused"))        global.paused        = false;
if (!variable_global_exists("pause_menu_id")) global.pause_menu_id = noone;

// Debounce
can_toggle = true;

// Fullscreen + GUI
window_set_fullscreen(true);
display_set_gui_size(1920, 1080);
display_set_gui_maximize(0, 0);

// Make sure the application surface is on (some projects turn it off)
application_surface_enable(true);

// Pause helpers — order matters
open_pause = function() {
    if (global.paused) return;

    // Freeze world but keep THIS instance active
    instance_deactivate_all(true);

    // Create menu AFTER deactivation so it remains active
    global.pause_menu_id = instance_create_depth(0, 0, -100000, oPauseMenu);

    audio_pause_all();
    global.paused = true;
};

close_pause = function() {
    if (!global.paused) return;

    if (instance_exists(global.pause_menu_id)) with (global.pause_menu_id) instance_destroy();
    global.pause_menu_id = noone;

    audio_resume_all();
    instance_activate_all();

    global.paused = false;
};


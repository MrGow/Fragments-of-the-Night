/// oMirrorTransition - Create
// --- Singleton guard ---
if (instance_number(object_index) > 1) {
    instance_destroy();
    exit;
}

// --- Global lock so callers can't spam transitions ---
if (!variable_global_exists("_transition_busy")) global._transition_busy = false;

enum Phase { Idle, Out, Switch, In }

phase        = Phase.Idle;
use_mirror   = true;
target_room  = noone;
target_spawn = undefined;

effect_time  = 0.50;
image_speed  = 0;
image_index  = 0;

visible      = false;

gui_w = display_get_gui_width();
gui_h = display_get_gui_height();
fade_alpha   = 0;

// --- start_out with lock + phase gate ---
start_out = function() {
    // If we’re already doing a transition (anywhere), ignore.
    if (global._transition_busy || phase != Phase.Idle) {
        // show_debug_message("[oMirrorTransition] start_out ignored (busy/active).");
        exit;
    }
    global._transition_busy = true; // <— lock

    if (use_mirror) {
        phase       = Phase.Out;
        visible     = true;
        fade_alpha  = 0;
        image_index = 0;
        image_speed = sprite_get_number(sprite_index) / (room_speed * effect_time);
    } else {
        phase      = Phase.Out;
        visible    = true;
        fade_alpha = 0;
        image_speed = 0;
    }
};

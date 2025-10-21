/// oMirrorTransition - Create
// Make this object Persistent in the Object Editor.

// --- Singleton guard ---
if (instance_number(object_index) > 1) {
    instance_destroy();
    exit;
}

// --- Global lock so callers can't spam transitions ---
if (!variable_global_exists("_transition_busy")) global._transition_busy = false;

// Phases
enum Phase { Idle, Out, Switch, In }

phase        = Phase.Idle;
use_mirror   = true;

// IMPORTANT: initialize with a *room asset* for proper typing
target_room  = room;          // << was `noone` before (wrong type)
target_spawn = undefined;

// Timing/anim
effect_time  = 0.50;
image_speed  = 0;
image_index  = 0;

visible      = false;
fade_alpha   = 0;

// GUI size cache
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

// --- start_out with lock + phase gate ---
start_out = function() {
    if (global._transition_busy || phase != Phase.Idle) exit;
    global._transition_busy = true; // lock

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

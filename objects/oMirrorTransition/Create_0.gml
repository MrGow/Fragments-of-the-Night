/// oMirrorTransition - Create
// Make this object Persistent in the Object Editor (property), not via code.

// --- Singleton guard ---
if (instance_number(object_index) > 1) {
    instance_destroy();
    exit;
}

// --- Global lock so callers can't spam transitions ---
if (!variable_global_exists("_transition_busy")) global._transition_busy = false;

// Phases
enum Phase { Idle, Out, Switch, In }

phase        = Phase.Idle;   // current phase
use_mirror   = true;         // OUT leg uses mirror; IN will switch to fade
target_room  = noone;        // destination room asset
target_spawn = undefined;    // optional spawn tag

// Timing/anim
effect_time  = 0.50;         // seconds for OUT or IN leg
image_speed  = 0;
image_index  = 0;

visible      = false;
fade_alpha   = 0;

// GUI size cache
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

// --- start_out with lock + phase gate ---
start_out = function() {
    // If we’re already doing a transition (anywhere), ignore.
    if (global._transition_busy || phase != Phase.Idle) {
        // show_debug_message("[oMirrorTransition] start_out ignored (busy/active).");
        exit;
    }
    global._transition_busy = true; // lock

    if (use_mirror) {
        // Shatter OUT: play sprite forward
        phase       = Phase.Out;
        visible     = true;
        fade_alpha  = 0;
        image_index = 0;
        image_speed = sprite_get_number(sprite_index) / (room_speed * effect_time);
    } else {
        // Fade OUT (not typical in this setup, but kept for completeness)
        phase      = Phase.Out;
        visible    = true;
        fade_alpha = 0;
        image_speed = 0;
    }
};

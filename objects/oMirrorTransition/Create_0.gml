/// oMirrorTransition - Create
// Make this object Persistent in the Object Editor.

// Singleton
if (instance_number(object_index) > 1) { instance_destroy(); exit; }

// Globals
if (!variable_global_exists("_transition_busy"))       global._transition_busy = false;
if (!variable_global_exists("_transition_cooldown_f")) global._transition_cooldown_f = 0;

// Phases & Modes
enum Phase    { Idle, Out, Switch, In, Hold }
enum PlayMode { ForwardOnly, ReverseOnly, ForwardThenReverse }

phase     = Phase.Idle;
play_mode = PlayMode.ForwardThenReverse;

use_mirror   = true;
target_room  = room;
target_spawn = undefined;

// Timing (seconds per leg)
effect_time_out = 0.85;   // shatter OUT
effect_time_in  = 0.85;   // rebuild IN
effect_time     = 0.50;   // legacy (not used)

// Leg timing (frame driven)
leg_frames      = 0;
leg_elapsed     = 0;
img_start       = 0;
img_end         = 0;

// Animation
image_speed  = 0;
image_index  = 0;
end_hold     = 0;         // final-frame hold (frames)
end_hold_len = 4;         // let last frame breathe

// Camera settle masks
settle_time_sec           = 0.45;                         // mask AFTER room_goto
settle_frames             = ceil(room_speed * settle_time_sec);
hold_alpha                = 1.0;

post_in_settle_time_sec   = 0.20;                         // brief mask AFTER reverse IN
post_in_settle_frames     = ceil(room_speed * post_in_settle_time_sec);

// GUI cache (optional)
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

// Start (no surface toggling anywhere)
start_out = function() {
    if (global._transition_busy) exit;
    if (global._transition_cooldown_f > 0) exit;
    if (phase != Phase.Idle) exit;

    global._transition_busy = true;

    phase       = Phase.Out;
    // leg_frames for OUT is set on the first Step tick (mode-aware)
    leg_frames  = 0;
    leg_elapsed = 0;
    end_hold    = 0;
    image_speed = 0; // we drive via leg timer + interpolation
};


/// oMirrorTransition - Create
// Make this object Persistent in the Object Editor.
if (instance_number(object_index) > 1) { instance_destroy(); exit; }

if (!variable_global_exists("_transition_busy"))       global._transition_busy = false;
if (!variable_global_exists("_transition_cooldown_f")) global._transition_cooldown_f = 0;

enum Phase    { Idle, Out, Switch, MaskUntilStable, In, Hold }
enum PlayMode { ForwardOnly, ReverseOnly, ForwardThenReverse }

phase     = Phase.Idle;
play_mode = PlayMode.ForwardThenReverse;

use_mirror   = true;
target_room  = room;
target_spawn = undefined;

// Timing
effect_time_out = 2.0;
effect_time_in  = 2.0;

// Leg timing / anim
leg_frames  = 0;
leg_elapsed = 0;
img_start   = 0;
img_end     = 0;

image_speed  = 0;
image_index  = 0;
end_hold     = 0;
end_hold_len = 4;

// Veil / holds
settle_time_sec = 0.45;
settle_frames   = ceil(room_speed * settle_time_sec);
hold_alpha      = 1.0;

// Mask-until-stable
stable_epsilon_px       = 0.25;
stable_required_frames  = 2;
stable_timeout_sec      = 0.50;
stable_timeout_frames   = ceil(room_speed * stable_timeout_sec);
cam_prev_x = 0; cam_prev_y = 0; cam_stable_n = 0; cam_timeout = 0;

// FX
shake_timer = 0;

// GUI cache
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

// Safety: ensure we have a shard sprite assigned
if (sprite_index == -1) {
    var _spr = asset_get_index("sprite_Mirror_Transition");
    if (_spr != -1) sprite_index = _spr;
}

// Defensive leftovers (unused but defined to avoid stray references)
cache_ready = false;
surf_cache  = -1;

// NEW: flag the script sets to start the transition
start_requested = false;

// NEW: one-shot guards so we don't re-post pose requests every frame
pose_queued_forward = false;
pose_queued_reverse = false;

/// oCamera - Create (early-pan + rescue)

target_obj = oPlayer;
target     = noone;

view_index = 0;
cam = view_camera[view_index];
camera_set_view_size(cam, 640, 360);

active_zone = noone;

// ---------- Early-pan tuning ----------
deadzone_frac_x  = 0.18;   // smaller = pans earlier (try 0.14–0.16 if you want more)
deadzone_frac_y  = 0.14;
deadzone_min_x   = 10;
deadzone_min_y   = 10;

pan_bias_max     = 40;     // forward shift of deadzone window
smooth_follow    = 0.15;
y_bias           = -12;

lookahead_max    = 64;
lookahead_lerp   = 0.18;
lookahead_x      = 0;

// Track previous x to derive dx for look-ahead
prev_px = 0;

// ---------- Rescue / handover ----------
handover_pad         = 8;   // require leaving the zone by this many px before auto-handover
transition_guard_max = 3;   // small guard after a door-triggered switch (prevents flicker)
transition_guard     = 0;

// Single instance safety
if (instance_number(oCamera) > 1) { instance_destroy(); exit; }



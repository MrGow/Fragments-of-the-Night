/// oCamera - Create (early-pan version)

target_obj = oPlayer;
target     = noone;

view_index = 0;
cam = view_camera[view_index];
camera_set_view_size(cam, 640, 360);

active_zone = noone;

// ---------- Early-pan tuning ----------
deadzone_frac_x  = 0.30;   // fraction of view width on each side (smaller = pans earlier)
deadzone_frac_y  = 0.14;   // fraction of view height (smaller = earlier)
deadzone_min_x   = 10;     // pixel floor
deadzone_min_y   = 10;

pan_bias_max     = 40;     // forward-shift of the deadzone window
smooth_follow    = 0.15;   // camera lerp
y_bias           = -12;    // lift camera to see above player

// Look-ahead driven by actual player movement (dx), not a specific var name
lookahead_max    = 80;     // px
lookahead_lerp   = 0.18;   // responsiveness
lookahead_x      = 0;      // runtime

// Track previous player x to compute dx
prev_px = 0;

// Single instance safety
if (instance_number(oCamera) > 1) { instance_destroy(); exit; }



/// oCamera - Step (early pan + look-ahead inside zone)
if (!instance_exists(active_zone)) exit;

// Resolve target if needed
if (!instance_exists(target)) {
    var p = instance_find(target_obj, 0);
    if (p != noone) target = p; else exit;
}

var vw = camera_get_view_width(cam);
var vh = camera_get_view_height(cam);

var vx = camera_get_view_x(cam);
var vy = camera_get_view_y(cam);

// Zone rect and size
var zl = active_zone.left;
var zt = active_zone.top;
var zr = active_zone.right;
var zb = active_zone.bottom;

var zw = zr - zl;
var zh = zb - zt;

// Compute deadzone sizes in pixels
var dzx = max(deadzone_min_x, round(vw * deadzone_frac_x));
var dzy = max(deadzone_min_y, round(vh * deadzone_frac_y));

// Current player pos (with vertical bias)
var px = target.x;
var py = target.y + y_bias;

// Player horizontal delta since last step (robust look-ahead driver)
var dx = px - prev_px;
prev_px = px;

// Desired look-ahead (from dx)
var desired_look = clamp(dx * 16, -lookahead_max, lookahead_max); // 16 = tune factor
lookahead_x = lerp(lookahead_x, desired_look, lookahead_lerp);

// Shift the deadzone window forward a bit in the travel direction
var dz_shift_x = clamp(lookahead_x, -pan_bias_max, pan_bias_max);

// Start desired top-left from current view
var tx = vx;
var ty = vy;

// ---------------- X AXIS ----------------
if (zw <= vw) {
    // Zone narrower than view: center in zone
    tx = zl + (zw - vw) * 0.5;
} else {
    // Wider zone: early pan with forward-shifted deadzone
    var focus_x = px + lookahead_x;       // where we want to bias toward
    var dzl = vx + dzx + dz_shift_x;      // left edge of deadzone window
    var dzr = vx + vw - dzx + dz_shift_x; // right edge

    if (focus_x < dzl)        tx = focus_x - (dzx + dz_shift_x);
    else if (focus_x > dzr)   tx = focus_x - (vw - (dzx - dz_shift_x));

    // Clamp to zone bounds
    tx = clamp(tx, zl, zr - vw);
}

// ---------------- Y AXIS ----------------
if (zh <= vh) {
    ty = zt + (zh - vh) * 0.5;
} else {
    var dzt = vy + dzy;
    var dzb = vy + vh - dzy;

    if (py < dzt)        ty = py - dzy;
    else if (py > dzb)   ty = py - (vh - dzy);

    ty = clamp(ty, zt, zb - vh);
}

// ---------------- Smooth apply ----------------
var nx = lerp(vx, tx, smooth_follow);
var ny = lerp(vy, ty, smooth_follow);

// Snap to whole pixels to avoid shimmer
if (abs(nx - tx) <= 0.5) nx = tx;
if (abs(ny - ty) <= 0.5) ny = ty;

camera_set_view_pos(cam, round(nx), round(ny));


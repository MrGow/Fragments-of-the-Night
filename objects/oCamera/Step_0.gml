/// oCamera - Step (early pan + auto rescue to player's zone)
if (transition_guard > 0) transition_guard--;

// Resolve target if needed
if (!instance_exists(target)) {
    var p = instance_find(target_obj, 0);
    if (p != noone) target = p; else exit;
}

var vw = camera_get_view_width(cam);
var vh = camera_get_view_height(cam);

var vx = camera_get_view_x(cam);
var vy = camera_get_view_y(cam);

// ---------------- RESCUE / HANDOVER ----------------
// If the player has actually left the current zone (with a small pad),
// immediately switch the active zone to whichever zone contains the player.
// This prevents the camera from staying behind when you pivot back quickly.
if (instance_exists(active_zone)) {
    var zl = active_zone.left;
    var zt = active_zone.top;
    var zr = active_zone.right;
    var zb = active_zone.bottom;

    if (!point_in_rectangle(target.x, target.y,
        zl + handover_pad, zt + handover_pad,
        zr - handover_pad, zb - handover_pad))
    {
        // Only auto-switch if we're not in the very first frames of a door transition
        if (transition_guard <= 0) {
            var nz = noone;
            with (oCamZone) {
                if (point_in_rectangle(other.target.x, other.target.y, left, top, right, bottom)) {
                    nz = id; break;
                }
            }
            if (nz != noone && nz != active_zone) {
                active_zone = nz;
            }
        }
    }
} else {
    // No active zone yet? Try to acquire one that contains the player
    var grab = noone;
    with (oCamZone) {
        if (point_in_rectangle(other.target.x, other.target.y, left, top, right, bottom)) {
            grab = id; break;
        }
    }
    if (grab != noone) active_zone = grab; else exit;
}

// After rescue, recompute zone rect
var zl = active_zone.left;
var zt = active_zone.top;
var zr = active_zone.right;
var zb = active_zone.bottom;

var zw = zr - zl;
var zh = zb - zt;

// ---------- compute deadzone in pixels ----------
var dzx = max(deadzone_min_x, round(vw * deadzone_frac_x));
var dzy = max(deadzone_min_y, round(vh * deadzone_frac_y));

// ---------- look-ahead from dx (robust) ----------
var px = target.x;
var py = target.y + y_bias;

var dx = px - prev_px;
prev_px = px;

var desired_look = clamp(dx * 16, -lookahead_max, lookahead_max); // 16 is a feel factor
lookahead_x = lerp(lookahead_x, desired_look, lookahead_lerp);

var dz_shift_x = clamp(lookahead_x, -pan_bias_max, pan_bias_max);

// Desired top-left starts from current view
var tx = vx;
var ty = vy;

// ---------------- X AXIS ----------------
if (zw <= vw) {
    // zone narrower than the view: center within zone
    tx = zl + (zw - vw) * 0.5;
} else {
    var focus_x = px + lookahead_x;
    var win_l   = vx + dzx + dz_shift_x;
    var win_r   = vx + vw - dzx + dz_shift_x;

    if (focus_x < win_l)        tx = focus_x - (dzx + dz_shift_x);
    else if (focus_x > win_r)   tx = focus_x - (vw - (dzx - dz_shift_x));

    tx = clamp(tx, zl, zr - vw);
}

// ---------------- Y AXIS ----------------
if (zh <= vh) {
    ty = zt + (zh - vh) * 0.5;
} else {
    var win_t = vy + dzy;
    var win_b = vy + vh - dzy;

    if (py < win_t)        ty = py - dzy;
    else if (py > win_b)   ty = py - (vh - dzy);

    ty = clamp(ty, zt, zb - vh);
}

// ---------------- Smooth apply ----------------
var nx = lerp(vx, tx, smooth_follow);
var ny = lerp(vy, ty, smooth_follow);

// Pixel snap to avoid shimmer
if (abs(nx - tx) <= 0.5) nx = tx;
if (abs(ny - ty) <= 0.5) ny = ty;

camera_set_view_pos(cam, round(nx), round(ny));

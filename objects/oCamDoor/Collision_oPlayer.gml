/// oCamDoor - Collision with oPlayer
if (activate_in > 0 || cooldown > 0 || !armed) exit;

var cam = instance_find(oCamera, 0);
if (cam == noone) exit;

// reset zone hits
z_hit0 = noone; z_hit1 = noone;

with (cam) transition_guard = transition_guard_max;


// current camera zone (if any)
var z_cur = noone;
if (instance_exists(cam.active_zone)) z_cur = cam.active_zone;

// gather up to two zones overlapping THIS door’s bbox
with (oCamZone) {
    if (left   < other.bbox_right &&
        right  > other.bbox_left  &&
        top    < other.bbox_bottom &&
        bottom > other.bbox_top)
    {
        if (other.z_hit0 == noone) other.z_hit0 = id;
        else if (other.z_hit1 == noone) other.z_hit1 = id;
    }
}

// decide destination
var z_dst = noone;

// If two neighbors: choose by player movement direction (stable)
if (z_hit0 != noone && z_hit1 != noone) {
    var p  = other; // door as 'other' here; we need player instance:
    var pl = instance_nearest(x, y, oPlayer);
    if (pl != noone) {
        var dx = pl.x - pl.xprevious;
        var dy = pl.y - pl.yprevious;

        // find zone centers
        var z0cx = (z_hit0.left + z_hit0.right) * 0.5;
        var z1cx = (z_hit1.left + z_hit1.right) * 0.5;
        var z0cy = (z_hit0.top  + z_hit0.bottom) * 0.5;
        var z1cy = (z_hit1.top  + z_hit1.bottom) * 0.5;

        if (abs(dx) >= abs(dy)) {
            // horizontal intent
            z_dst = (dx >= 0) ? (z1cx > z0cx ? z_hit1 : z_hit0)
                              : (z1cx < z0cx ? z_hit1 : z_hit0);
        } else {
            // vertical intent
            z_dst = (dy >= 0) ? (z1cy > z0cy ? z_hit1 : z_hit0)
                              : (z1cy < z0cy ? z_hit1 : z_hit0);
        }
    }
}

// If only one neighbor and it's not current, use it
if (z_dst == noone && z_hit0 != noone && z_hit0 != z_cur) z_dst = z_hit0;

// Fallback by name
if (z_dst == noone && target_zone_name != "") {
    with (oCamZone) {
        if (string(zone_name) == string(other.target_zone_name)) { z_dst = id; break; }
    }
}

if (z_dst == noone) exit;

// ---- perform transition ----
with (cam) {
    active_zone = z_dst;

    var vw = camera_get_view_width(cam);
    var vh = camera_get_view_height(cam);

    var tx = clamp(z_dst.left + (z_dst.right - z_dst.left - vw) * 0.5, z_dst.left, z_dst.right - vw);
    var ty = clamp(z_dst.top  + (z_dst.bottom- z_dst.top  - vh) * 0.5, z_dst.top,  z_dst.bottom - vh);

    tview_x = round(tx);
    tview_y = round(ty);

    if (other.use_fade && instance_exists(oFade)) {
        do_snap_after_fade = true;
        pending_view_x = tview_x;
        pending_view_y = tview_y;
        with (oFade) start_fade_out_in();
    } else {
        camera_set_view_pos(cam, tview_x, tview_y);
    }
}

// disarm until player exits; add cooldown and nudge player past the gate
armed    = false;
cooldown = cooldown_max;

// nudge player into the destination zone to avoid immediate re-collision
var pl = other; // 'other' is the player in this Collision event
if (pl != noone) {
    var dx = pl.x - pl.xprevious;
    var dy = pl.y - pl.yprevious;

    if (abs(dx) >= abs(dy)) {
        pl.x += (dx >= 0) ? 4 : -4;
    } else {
        pl.y += (dy >= 0) ? 4 : -4;
    }
}

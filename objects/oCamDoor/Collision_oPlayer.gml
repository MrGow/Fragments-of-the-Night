/// oCamDoor - Collision with oPlayer
if (activate_in > 0 || cooldown > 0) exit;

var cam = instance_find(oCamera, 0);
if (cam == noone) exit;

// reset hit slots on THIS door instance so WITH(...) can fill them
z_hit0 = noone;
z_hit1 = noone;

// current active zone from camera (if any)
var z_cur = noone;
if (instance_exists(cam.active_zone)) z_cur = cam.active_zone;

// Find up to two zones that overlap THIS door's bbox.
// Inside WITH(oCamZone): self = zone, other = THIS oCamDoor instance.
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

// Decide destination zone
var z_dst = noone;

if (z_hit0 != noone && z_hit1 != noone) {
    // two neighbors: go to the one that's NOT current
    z_dst = (z_cur == z_hit0) ? z_hit1 : z_hit0;
} else if (z_hit0 != noone && z_hit0 != z_cur) {
    // single neighbor and it's not current
    z_dst = z_hit0;
} else if (target_zone_name != "") {
    // named fallback
    with (oCamZone) {
        if (string(zone_name) == string(other.target_zone_name)) { z_dst = id; break; }
    }
}

if (z_dst == noone) exit;

// Do the transition (optional fade)
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

// Guard against immediate re-trigger
cooldown = cooldown_max;

// Optional: tiny nudge to avoid re-colliding the same frame
if (abs(bbox_right - other.bbox_left) < 4) other.x += 2;
if (abs(bbox_left  - other.bbox_right) < 4) other.x -= 2;
if (abs(bbox_bottom- other.bbox_top) < 4) other.y += 2;
if (abs(bbox_top   - other.bbox_bottom) < 4) other.y -= 2;

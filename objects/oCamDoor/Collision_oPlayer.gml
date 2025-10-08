/// oCamDoor - Collision with oPlayer
var cam = instance_find(oCamera, 0);
if (cam == noone) exit;

// Pick a target zone: either by `target_zone_id`, by name, or by “zone I’m overlapping”
var z = noone;

// 1) Direct id (set in instance vars)
if (variable_instance_exists(id, "target_zone_id") && instance_exists(target_zone_id)) {
    z = target_zone_id;
}

// 2) By name
if (z == noone && variable_instance_exists(id, "target_zone_name")) {
    with (oCamZone) {
        if (string(zone_name) == string(other.target_zone_name)) { z = id; break; }
    }
}

// 3) Fallback: zone under this door
if (z == noone) {
    with (oCamZone) {
        if (point_in_rectangle(other.x, other.y, left, top, right, bottom)) { z = id; break; }
    }
}

if (z == noone) exit;

// Assign and snap now
with (cam) {
    active_zone = z;
    var vw = camera_get_view_width(cam);
    var vh = camera_get_view_height(cam);

    var tx = clamp(z.left + (z.right - z.left - vw) * 0.5, z.left, z.right - vw);
    var ty = clamp(z.top  + (z.bottom- z.top  - vh) * 0.5, z.top,  z.bottom - vh);

    tview_x = round(tx);
    tview_y = round(ty);
    camera_set_view_pos(cam, tview_x, tview_y);
}

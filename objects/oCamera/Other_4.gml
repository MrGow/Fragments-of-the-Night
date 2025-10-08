/// oCamera - Room Start
view_index = 0;
cam = view_camera[view_index];
camera_set_view_size(cam, 640, 360);

// resolve target
if (!instance_exists(target)) {
    var p = instance_find(target_obj, 0);
    if (p != noone) target = p;
}
if (!instance_exists(target)) exit;

// find zone containing the player (zones have up-to-date rects from their Step)
var z = noone;
with (oCamZone) {
    if (point_in_rectangle(other.target.x, other.target.y, left, top, right, bottom)) {
        z = id; break;
    }
}

// choose a zone (player’s zone preferred, else first)
if (z == noone && instance_number(oCamZone) > 0) {
    z = instance_find(oCamZone, 0);
}
if (z != noone) {
    active_zone = z;
    var vw = camera_get_view_width(cam);
    var vh = camera_get_view_height(cam);
    var tx = clamp(z.left + (z.right - z.left - vw) * 0.5, z.left, z.right - vw);
    var ty = clamp(z.top  + (z.bottom- z.top  - vh) * 0.5, z.top,  z.bottom - vh);
    tview_x = round(tx); tview_y = round(ty);
    camera_set_view_pos(cam, tview_x, tview_y);
} else if (instance_exists(target)) {
    // fallback: center on player
    var vw = camera_get_view_width(cam);
    var vh = camera_get_view_height(cam);
    var tx = clamp(round(target.x - vw * 0.5), 0, max(0, room_width  - vw));
    var ty = clamp(round(target.y - vh * 0.5), 0, max(0, room_height - vh));
    tview_x = tx; tview_y = ty;
    camera_set_view_pos(cam, tx, ty);
}

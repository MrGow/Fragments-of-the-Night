// oCamera End Step — single move block

var cam = view_camera[0];
var cx  = camera_get_view_x(cam);
var cy  = camera_get_view_y(cam);

// Use easing only when locked; grid mode hard-snaps
var ease = lock_enabled ? smooth_snap : 1.0;

if (ease == 1.0) {
    // instant snap to the current grid cell target
    cx = tview_x;
    cy = tview_y;
} else {
    // smooth pan inside lock regions
    cx = lerp(cx, tview_x, ease);
    cy = lerp(cy, tview_y, ease);

    // epsilon clamp so we actually land on exact pixels
    if (abs(cx - tview_x) <= 0.5) cx = tview_x;
    if (abs(cy - tview_y) <= 0.5) cy = tview_y;
}

camera_set_view_pos(cam, round(cx), round(cy));


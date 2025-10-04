if (!instance_exists(follow)) exit;

// Read player
var px   = follow.x;
var py   = follow.y;
var phsp = variable_instance_exists(follow, "hsp") ? follow.hsp : 0;
var on_ground = place_meeting(follow.x, follow.y + 1, o_solid);

// Choose vertical anchor based on state (grounded vs air)
var anchor_y = on_ground ? anchor_y_ground : anchor_y_air;

// Horizontal look-ahead based on player horizontal speed
var la_target = clamp(phsp * 6, -look_x_max, look_x_max);  // scale speed → pixels
la_x = lerp(la_x, la_target, 0.15);

// Desired camera top-left so that player sits at (anchor_x, anchor_y)
var target_x = px - cam_w * anchor_x + la_x;
var target_y = py - cam_h * anchor_y;

// Smooth to target
var cx = camera_get_view_x(cam);
var cy = camera_get_view_y(cam);
cx = lerp(cx, target_x, smooth);
cy = lerp(cy, target_y, smooth);

// Clamp to room
cx = clamp(cx, pad_left, room_width  - cam_w - pad_right);
cy = clamp(cy, pad_top,  room_height - cam_h - pad_bottom);

// Pixel snap to avoid shimmer
if (snap >= 1) {
    cx = floor(cx / snap) * snap;
    cy = floor(cy / snap) * snap;
}

// Apply
camera_set_view_pos(cam, cx, cy);

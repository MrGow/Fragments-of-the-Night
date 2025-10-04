if (!instance_exists(follow)) exit;

var px = follow.x, py = follow.y;
var phsp = variable_instance_exists(follow,"hsp") ? follow.hsp : 0;
var on_ground = place_meeting(px, py+1, o_solid);

var anchor_y = on_ground ? anchor_y_ground : anchor_y_air;

// look-ahead
var la_target = clamp(phsp * 6, -look_x_max, look_x_max);
la_x = lerp(la_x, la_target, 0.15);

// desired camera top-left so player sits at the anchor
var target_x = px - cam_w * anchor_x + la_x;
var target_y = py - cam_h * anchor_y;

// smooth
var cx = lerp(camera_get_view_x(cam), target_x, smooth);
var cy = lerp(camera_get_view_y(cam), target_y, smooth);

// clamp to room
cx = clamp(cx, 0, room_width  - cam_w);
cy = clamp(cy, 0, room_height - cam_h);

// pixel snap
cx = floor(cx / snap) * snap;
cy = floor(cy / snap) * snap;

camera_set_view_pos(cam, cx, cy);

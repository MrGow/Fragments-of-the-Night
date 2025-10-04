/// scr_input_rumble(_left, _right, _frames)
// Usage: with (oInput) scr_input_rumble(0.8, 0.6, 10);
function scr_input_rumble(_l, _r, _frames) {
    rumble_left   = clamp(_l, 0, 1);
    rumble_right  = clamp(_r, 0, 1);
    rumble_frames = max(0, _frames | 0);
}

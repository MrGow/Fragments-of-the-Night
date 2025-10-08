/// oFade Step
if (state == 1) {
    // Fading out
    alpha = clamp(alpha + speed, 0, 1);
    if (!callback_ok && alpha >= 0.95) {
        // Tell camera to perform the pending snap exactly once
        var cam = instance_find(oCamera, 0);
        if (cam != noone && cam.do_snap_after_fade) {
            cam.snap_now();
            cam.do_snap_after_fade = false;
        }
        callback_ok = true;
    }
    if (alpha >= 1) {
        // Switch to fade in
        state = 2;
    }
} else if (state == 2) {
    // Fading in
    alpha = clamp(alpha - speed, 0, 1);
    if (alpha <= 0) {
        state = 0;
        callback_ok = false;
    }
}

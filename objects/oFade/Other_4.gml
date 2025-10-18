/// oFade - Room Start
if (state == 3 || alpha >= 1) state = 2;

/// oFade — Room Start (append)
if (!is_undefined(global.input)) {
    // Safety: if a portal set a global lock, ensure we clear it as the new room begins.
    global.input.input_enabled = true;
    global.input.player_locked = false;
    global.input.ui_captured   = false;
}


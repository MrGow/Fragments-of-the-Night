/// oMirrorTransition - Step
switch (phase) {

    case Phase.Out:
        if (use_mirror) {
            if (image_index >= image_number - 1) {
                phase = Phase.Switch;
            }
        } else {
            fade_alpha = clamp(fade_alpha + (1 / (effect_time * room_speed)), 0, 1);
            if (fade_alpha >= 1) {
                phase = Phase.Switch;
            }
        }
    break;

    case Phase.Switch:
        // Only switch if the target is a valid room asset
        if (room_exists(target_room)) {
            global._transition_spawn_tag = target_spawn;
            room_goto(target_room);
            // Room Start continues the IN leg.
        } else {
            show_debug_message("[oMirrorTransition] ERROR: target_room is not a valid room asset: " + string(target_room));
            phase    = Phase.Idle;
            visible  = false;
            image_speed = 0;
            global._transition_busy = false; // unlock on failure
        }
    break;

    case Phase.In:
        if (use_mirror) {
            if (image_index <= 0) {
                phase    = Phase.Idle;
                visible  = false;
                image_speed = 0;
                global._transition_busy = false; // unlock
            }
        } else {
            fade_alpha = clamp(fade_alpha - (1 / (effect_time * room_speed)), 0, 1);
            if (fade_alpha <= 0) {
                phase    = Phase.Idle;
                visible  = false;
                global._transition_busy = false; // unlock
            }
        }
    break;
}

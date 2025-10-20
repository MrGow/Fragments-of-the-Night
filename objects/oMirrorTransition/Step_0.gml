/// oMirrorTransition - Step

switch (phase) {

    case Phase.Out:
        if (use_mirror) {
            // Shatter anim plays forward. image_speed was set in start_out().
            // When we hit the last frame, switch rooms.
            if (image_index >= image_number - 1) {
                phase = Phase.Switch;
            }
        } else {
            // Fade to black
            fade_alpha = clamp(fade_alpha + (1 / (effect_time * room_speed)), 0, 1);
            if (fade_alpha >= 1) {
                phase = Phase.Switch;
            }
        }
    break;


    case Phase.Switch:
        // Safety: only switch if the target is a valid room asset
        if (room_exists(target_room)) {
            // Pass along the spawn tag globally so Room Start can position the player
            global._transition_spawn_tag = target_spawn;

            // Change rooms; the instance is persistent so it survives the switch
            room_goto(target_room);
            // NOTE: Room Start continues the "IN" leg (fade or reverse anim).
        } else {
            // If something passed a bad room, fail gracefully and unlock
            show_debug_message("[oMirrorTransition] ERROR: target_room is not a valid room asset: " + string(target_room));
            phase    = Phase.Idle;
            visible  = false;
            image_speed = 0;
            global._transition_busy = false;
        }
    break;


    case Phase.In:
        if (use_mirror) {
            // Reverse play back to frame 0 (only used if your Room Start chose reverse)
            if (image_index <= 0) {
                phase    = Phase.Idle;
                visible  = false;
                image_speed = 0;
                global._transition_busy = false; // unlock
            }
        } else {
            // Fade from black to clear (used by the single-pass shatter + fade-in path)
            fade_alpha = clamp(fade_alpha - (1 / (effect_time * room_speed)), 0, 1);
            if (fade_alpha <= 0) {
                phase    = Phase.Idle;
                visible  = false;
                global._transition_busy = false; // unlock
            }
        }
    break;
}

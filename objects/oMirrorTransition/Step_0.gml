/// oMirrorTransition - Step
switch (phase) {

    case Phase.Out:
        if (use_mirror) {
            // Advance shatter animation forward
            // (image_speed already set in Create or on restart)
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
        // Move rooms. Keep this instance (persistent) so we can play IN on the other side.
        // If you use a spawn system, stash the desired tag globally.
        global._transition_spawn_tag = target_spawn;
        room_goto(target_room);
        // NOTE: We will continue this logic in Room Start event (below).
    break;

	case Phase.In:
		if (use_mirror) {
			if (image_index <= 0) {
				phase    = Phase.Idle;
				visible  = false;
				image_speed = 0;
				global._transition_busy = false; // <— unlock
			}
		} else {
			fade_alpha = clamp(fade_alpha - (1 / (effect_time * room_speed)), 0, 1);
			if (fade_alpha <= 0) {
				phase    = Phase.Idle;
				visible  = false;
				global._transition_busy = false; // <— unlock
			}
		}
break;

}

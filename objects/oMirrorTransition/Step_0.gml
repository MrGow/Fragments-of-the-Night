/// oMirrorTransition - Step
if (global._transition_cooldown_f > 0) global._transition_cooldown_f--;

// Smooth weighty motion
function __ease_in_out_cubic(x) {
    return (x < 0.5)
        ? 4.0 * x * x * x
        : 1.0 - power(-2.0 * x + 2.0, 3.0) * 0.5;
}

function __finish_and_unlock() {
    phase       = Phase.Idle;
    image_speed = 0;
    global._transition_busy = false;
    global._transition_cooldown_f = max(global._transition_cooldown_f, room_speed / 4);
}

switch (phase) {
    case Phase.Out:
    {
        // Set up subimage range & duration on first tick
        if (leg_elapsed == 0 && end_hold == 0) {
            var frames = max(1, sprite_get_number(sprite_index));
            if (play_mode == PlayMode.ForwardOnly || play_mode == PlayMode.ForwardThenReverse) {
                img_start = 0;            // shatter forward
                img_end   = frames - 1;
            } else {
                img_start = frames - 1;   // reverse build
                img_end   = 0;
            }
            img_start = clamp(img_start, 0, frames - 1);
            img_end   = clamp(img_end,   0, frames - 1);

            // OUT duration (slower)
            leg_frames  = max(1, ceil(room_speed * effect_time_out));
            leg_elapsed = 0;
        }

        // Advance leg (time → eased subimage)
        leg_elapsed++;
        var t  = clamp(leg_elapsed / max(1, leg_frames), 0, 1);
        var te = __ease_in_out_cubic(t);
        image_index = lerp(img_start, img_end, te);

        // End with tiny frame-hold to show final frame
        if (t >= 1.0) {
            if (end_hold < end_hold_len) end_hold++;
            else phase = Phase.Switch;
        }
    }
    break;

    case Phase.Switch:
    {
        if (room_exists(target_room)) {
            global._transition_spawn_tag = target_spawn;
            room_goto(target_room);
            // Next leg decided in Room Start
        } else {
            show_debug_message("[oMirrorTransition] ERROR: invalid target_room " + string(target_room));
            __finish_and_unlock();
        }
    }
    break;

    case Phase.In:
    {
        // Reverse leg already configured in Room Start (incl. leg_frames for IN)
        leg_elapsed++;
        var t  = clamp(leg_elapsed / max(1, leg_frames), 0, 1);
        var te = __ease_in_out_cubic(t);
        image_index = lerp(img_start, img_end, te);

        if (t >= 1.0) {
            if (end_hold < end_hold_len) {
                end_hold++;
            } else {
                // After reverse IN, brief post-IN hold to hide any late snap
                phase            = Phase.Hold;
                hold_alpha       = 1.0;
                settle_frames    = max(1, ceil(room_speed * post_in_settle_time_sec));
            }
        }
    }
    break;

    case Phase.Hold:
    {
        // Fade veil (ease-out) so it feels smooth
        if (settle_frames > 0) {
            var denom = max(1, ceil(room_speed * ((hold_alpha >= 1.0 && phase == Phase.Hold) ? post_in_settle_time_sec : settle_time_sec)));
            var tt = 1.0 - (settle_frames / denom);
            hold_alpha = max(0, 1.0 - (tt * tt));
            settle_frames--;
        } else {
            // Reset + unlock
            settle_frames = ceil(room_speed * settle_time_sec);
            hold_alpha    = 0.0;
            __finish_and_unlock();
        }
    }
    break;
}

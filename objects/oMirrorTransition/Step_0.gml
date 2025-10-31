/// oMirrorTransition - Step
// Ensure the cooldown exists (avoid type warnings)
if (!variable_global_exists("_transition_cooldown_f")) global._transition_cooldown_f = 0;
if (global._transition_cooldown_f > 0) global._transition_cooldown_f--;

// Kick-off requested by the script (no direct function calls)
if (start_requested) {
    start_requested = false;
    if (!global._transition_busy && global._transition_cooldown_f <= 0 && phase == Phase.Idle) {
        global._transition_busy = true;
        phase       = Phase.Out;
        leg_frames  = 0;
        leg_elapsed = 0;
        end_hold    = 0;
        image_speed = 0;
    }
}

// cubic ease without power(); avoid built-in names
function __ease_in_out_cubic(tval) {
    if (tval < 0.5) {
        return 4.0 * tval * tval * tval;
    } else {
        var yy = (-2.0 * tval + 2.0);
        yy = yy * yy * yy;
        return 1.0 - (yy * 0.5);
    }
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
        if (leg_elapsed == 0 && end_hold == 0) {
            if (sprite_index == -1) { show_debug_message("[oMirrorTransition] No sprite assigned."); __finish_and_unlock(); break; }
            var frames = max(1, sprite_get_number(sprite_index));

            if (play_mode == PlayMode.ForwardOnly || play_mode == PlayMode.ForwardThenReverse) {
                img_start = 0;
                img_end   = frames - 1;
            } else {
                img_start = frames - 1;
                img_end   = 0;
            }
            img_start   = clamp(img_start, 0, frames - 1);
            img_end     = clamp(img_end,   0, frames - 1);
            leg_frames  = max(1, ceil(room_speed * effect_time_out));
            leg_elapsed = 0;
        }

        leg_elapsed++;
        var t  = clamp(leg_elapsed / max(1, leg_frames), 0, 1);
        var te = __ease_in_out_cubic(t);
        image_index = lerp(img_start, img_end, te);

        if (t >= 1.0) {
            if (end_hold < end_hold_len) end_hold++;
            else {
                shake_timer = max(shake_timer, round(room_speed * 0.10));
                phase = Phase.Switch;
            }
        }
    }
    break;

    case Phase.Switch:
    {
        if (room_exists(target_room)) {
            global._transition_spawn_tag = target_spawn;
            room_goto(target_room);
            // Next leg set in Room Start
        } else {
            show_debug_message("[oMirrorTransition] ERROR: invalid target_room " + string(target_room));
            __finish_and_unlock();
        }
    }
    break;

    case Phase.MaskUntilStable:
    {
        var cam = view_camera[0];
        var cx = camera_get_view_x(cam);
        var cy = camera_get_view_y(cam);

        if (cam_timeout > 0) cam_timeout--;

        if (cam_stable_n < 0) {
            cam_prev_x   = cx;
            cam_prev_y   = cy;
            cam_stable_n = 0;
        }

        var dx = abs(cx - cam_prev_x);
        var dy = abs(cy - cam_prev_y);
        var moved = (dx > stable_epsilon_px) || (dy > stable_epsilon_px);

        if (moved) {
            cam_stable_n = 0;
            cam_prev_x = cx; cam_prev_y = cy;
        } else {
            cam_stable_n++;
        }

        if (cam_stable_n >= stable_required_frames || cam_timeout <= 0) {
            if (sprite_index == -1) { __finish_and_unlock(); break; }
            var frames = max(1, sprite_get_number(sprite_index));
            img_start   = frames - 1;
            img_end     = 0;
            leg_frames  = max(1, ceil(room_speed * effect_time_in));
            leg_elapsed = 0;
            end_hold    = 0;
            phase       = Phase.In;

            // ===== PLAYER: reverse "walk out of mirror" on arrival (50% faster) =====
            var pl = instance_exists(oPlayer) ? instance_find(oPlayer, 0) : noone;
            if (pl != noone) with (pl) {
                if (!variable_instance_exists(id,"forced_anim_active"))  forced_anim_active  = false;
                if (!variable_instance_exists(id,"forced_anim_sprite"))  forced_anim_sprite  = -1;
                if (!variable_instance_exists(id,"forced_anim_speed"))   forced_anim_speed   = 0.45;
                if (!variable_instance_exists(id,"forced_anim_reverse")) forced_anim_reverse = false;
                if (!variable_instance_exists(id,"forced_anim_started")) forced_anim_started = false;

                forced_anim_sprite  = __spr("spritePlayerLookInwards");
                if (forced_anim_sprite == -1) forced_anim_sprite = spritePlayerLookInwards;
                forced_anim_speed   = 0.45;  // faster
                forced_anim_reverse = true;  // reverse on arrival
                forced_anim_active  = true;
                forced_anim_started = false;
            }
        }
    }
    break;

    case Phase.In:
    {
        leg_elapsed++;
        var t2  = clamp(leg_elapsed / max(1, leg_frames), 0, 1);
        var te2 = __ease_in_out_cubic(t2);
        image_index = lerp(img_start, img_end, te2);

        if (t2 >= 1.0) {
            if (end_hold < end_hold_len) {
                end_hold++;
            } else {
                shake_timer     = max(shake_timer, round(room_speed * 0.06));
                phase           = Phase.Hold;
                hold_alpha      = 1.0;
                settle_frames   = max(1, ceil(room_speed * settle_time_sec));
            }
        }
    }
    break;

    case Phase.Hold:
    {
        if (settle_frames > 0) {
            var denom = max(1, ceil(room_speed * settle_time_sec));
            var tt = 1.0 - (settle_frames / denom);
            hold_alpha = max(0, 1.0 - (tt * tt));
            settle_frames--;
        } else {
            settle_frames = ceil(room_speed * settle_time_sec);
            hold_alpha    = 0.0;
            __finish_and_unlock();
        }
    }
    break;
}

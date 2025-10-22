/// oMirrorTransition - Room Start
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

function __prep_leg_range(_from, _to) {
    leg_elapsed = 0;
    end_hold    = 0;
    img_start   = _from;
    img_end     = _to;
}

if (phase == Phase.Switch) {
    // -------- Spawn/tag placement (generic fallback) --------
    var _tag_local = global._transition_spawn_tag;
    global._transition_spawn_tag = undefined;

    if (!is_undefined(_tag_local)) {
        _spawn_tag_tmp = _tag_local; _placed_tmp = false;

        var _oSpawn = asset_get_index("oSpawn");
        if (_oSpawn != -1) {
            with (oSpawn) {
                var _match =
                    (variable_instance_exists(id, "tag")       && (tag == other._spawn_tag_tmp)) ||
                    (variable_instance_exists(id, "spawn_tag") && (spawn_tag == other._spawn_tag_tmp));
                if (_match) {
                    var _xx = x, _yy = y;
                    with (oPlayer) { x = _xx; y = _yy; }
                    other._placed_tmp = true;
                }
            }
        }
        if (!_placed_tmp) {
            with (all) {
                var _has_tag  = variable_instance_exists(id,"tag");
                var _has_stag = variable_instance_exists(id,"spawn_tag");
                if ( (_has_tag  && tag       == other._spawn_tag_tmp) ||
                     (_has_stag && spawn_tag == other._spawn_tag_tmp) ) {
                    var _xx = x, _yy = y;
                    with (oPlayer) { x = _xx; y = _yy; }
                    other._placed_tmp = true;
                }
            }
        }
        _spawn_tag_tmp = undefined;
    }

    // -------- Next leg --------
    var frames = max(1, sprite_get_number(sprite_index));
    if (play_mode == PlayMode.ForwardThenReverse) {
        // Reverse-shatter IN (end→start) with slower IN duration
        __prep_leg_range(frames - 1, 0);
        leg_frames  = max(1, ceil(room_speed * effect_time_in)); // slower IN
        leg_elapsed = 0;
        phase       = Phase.In;
    } else {
        // No IN leg → use the longer settle hold to hide cam snap
        phase         = Phase.Hold;
        hold_alpha    = 1.0;
        settle_frames = max(1, ceil(room_speed * settle_time_sec));
    }
}

/// oMirrorTransition - Room Start
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

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

    // -------- NEW: mask-until-stable setup --------
    // Start fully veiled to cover load & snap; wait for camera to settle.
    phase          = Phase.MaskUntilStable;
    hold_alpha     = 1.0;                            // full black veil
    cam_stable_n   = -1;                             // prime first-tick sampling
    cam_timeout    = max(1, stable_timeout_frames);  // safety timeout
}

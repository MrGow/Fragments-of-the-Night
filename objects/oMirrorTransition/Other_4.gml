/// oMirrorTransition - Room Start (single-pass shatter → fade-in)

// Refresh GUI dims
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

if (phase == Phase.Switch) {
    // IN leg = fade instead of reverse-shatter
    use_mirror = false;
    fade_alpha = 1;
    image_speed = 0;
    phase = Phase.In;

    // ----------------------------
    // OPTIONAL: spawn/tag handling (generic fallback only)
    // ----------------------------
    var _tag_local = global._transition_spawn_tag;
    global._transition_spawn_tag = undefined;

    if (!is_undefined(_tag_local)) {
        _spawn_tag_tmp = _tag_local;  // temp var for 'other' in with()
        _placed_tmp    = false;

        // Prefer a dedicated oSpawn if present
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

        // Fallback: scan any instance exposing tag/spawn_tag
        if (!_placed_tmp) {
            with (all) {
                var _has_tag  = variable_instance_exists(id, "tag");
                var _has_stag = variable_instance_exists(id, "spawn_tag");
                if ( (_has_tag  && tag       == other._spawn_tag_tmp) ||
                     (_has_stag && spawn_tag == other._spawn_tag_tmp) ) {
                    var _xx = x, _yy = y;
                    with (oPlayer) { x = _xx; y = _yy; }
                    other._placed_tmp = true;
                }
            }
        }

        _spawn_tag_tmp = undefined; // cleanup
    }

    // Optional: SaveRoom hook — only if you actually implement it later.
    // (Removed script_execute to avoid type errors)
    // var _enter_sr = asset_get_index("scr_on_enter_saveroom");
    // if (room == SaveRoom && _enter_sr != -1) { /* call your function directly here when it exists */ }
}

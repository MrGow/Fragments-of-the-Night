/// oMirrorTransition - Room Start (single-pass shatter → fade-in)

// Refresh GUI dims in case resolution changed
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

if (phase == Phase.Switch) {
    // IN direction = fade instead of reverse-shatter
    use_mirror = false;    // ensure Step does the fade branch
    fade_alpha = 1;
    image_speed = 0;
    phase = Phase.In;

    // ----------------------------
    // OPTIONAL: spawn/tag handling
    // ----------------------------
    var _tag_local = global._transition_spawn_tag;
    global._transition_spawn_tag = undefined;

    if (!is_undefined(_tag_local)) {
        // If a spawn script exists, call it safely by name
        var _spawn_script = asset_get_index("scr_spawn_at_tag");
        if (_spawn_script != -1) {
            // call: function scr_spawn_at_tag(tag)
            script_execute(_spawn_script, _tag_local);
        } else {
            // Generic fallback: move player to any instance with matching tag/spawn_tag
            _spawn_tag_tmp = _tag_local;  // temp instance var for 'other' access in with()
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

            // Clean up temp
            _spawn_tag_tmp = undefined;
        }
    }

    // Optional: hook for entering SaveRoom
    var _enter_sr = asset_get_index("scr_on_enter_saveroom");
    if (room == SaveRoom && _enter_sr != -1) {
        script_execute(_enter_sr);
    }
}


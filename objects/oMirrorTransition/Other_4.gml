/// oMirrorTransition - Room Start (SAFE, no undefined reads)

// Refresh GUI dims in case resolution changed
gui_w = display_get_gui_width();
gui_h = display_get_gui_height();

if (phase == Phase.Switch) {
    // Play IN direction
    if (use_mirror) {
        image_index = image_number - 1;
        image_speed = -sprite_get_number(sprite_index) / (room_speed * effect_time);
    } else {
        fade_alpha = 1;
    }
    phase = Phase.In;

    // ----------------------------
    // OPTIONAL: spawn/tag handling
    // ----------------------------
    var _tag_local = global._transition_spawn_tag;
    global._transition_spawn_tag = undefined;

    if (!is_undefined(_tag_local)) {
        // If you later add scr_spawn_at_tag(tag), we will call it.
        var _spawn_script = asset_get_index("scr_spawn_at_tag");
        if (_spawn_script != -1) {
            script_execute(_spawn_script, _tag_local);
        } else {
            // Make the tag accessible inside `with(...)` safely
            _spawn_tag_tmp = _tag_local;   // <-- instance var on THIS oMirrorTransition
            _placed_tmp    = false;        // <-- instance var placement flag

            // Prefer oSpawn if present
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

            // Fallback: scan any instance that exposes tag/spawn_tag
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

            // Clean up temps (not strictly required)
            _spawn_tag_tmp = undefined;
        }
    }

    // Optional: call a SaveRoom hook safely if you add one later
    var _enter_sr = asset_get_index("scr_on_enter_saveroom");
    if (room == SaveRoom && _enter_sr != -1) {
        script_execute(_enter_sr);
    }
}

/// script_transition_goto(_room_asset, _spawn_tag_or_undefined)
//
// _room_asset: a room asset (e.g., SaveRoom)
// _spawn_tag_or_undefined: string tag or undefined

function script_transition_goto(_room_asset, _spawn) {
    // Guards: busy or cooldown?
    if (variable_global_exists("_transition_busy") && global._transition_busy) return;
    if (variable_global_exists("_transition_cooldown_f") && global._transition_cooldown_f > 0) return;

    // Target must be a valid room asset
    if (!room_exists(_room_asset)) {
        show_debug_message("[transition_goto] Invalid target room asset: " + string(_room_asset));
        return;
    }

    // Pick a layer: prefer "FX", else "actors", else first instance layer
    var _layer_name = "FX";
    if (layer_get_id(_layer_name) == -1) {
        if (layer_get_id("actors") != -1) _layer_name = "actors";
        else {
            var _ids = layer_get_all();
            for (var i = 0; i < array_length(_ids); i++) {
                if (layer_get_type(_ids[i]) == layertype_instances) {
                    _layer_name = layer_get_name(_ids[i]); break;
                }
            }
        }
    }

    // Singleton transition object
    var tr = instance_exists(oMirrorTransition) ? instance_find(oMirrorTransition, 0)
                                                : instance_create_layer(0, 0, _layer_name, oMirrorTransition);

    // Compute these in the caller scope
    var _to_save   = (_room_asset == SaveRoom);
    var _from_save = (room == SaveRoom);

    // Stash onto the transition instance so we can read them inside the 'with'
    tr.__to_save   = _to_save;
    tr.__from_save = _from_save;

    // Configure + start
    with (tr) {
        // Destination + spawn
        target_room  = argument0; // _room_asset
        target_spawn = is_undefined(argument1) ? undefined : string(argument1);

        // Import the flags we stashed
        var to_save   = __to_save;
        var from_save = __from_save;

        // Decide play mode:
        // - entering SaveRoom  → ForwardOnly (shatter), switch, done
        // - leaving  SaveRoom  → ReverseOnly (rebuild), switch, done
        // - otherwise          → ForwardThenReverse
        if (to_save && !from_save)       play_mode = PlayMode.ForwardOnly;
        else if (!to_save && from_save)  play_mode = PlayMode.ReverseOnly;
        else                              play_mode = PlayMode.ForwardThenReverse;

        // Clean up temps
        __to_save   = undefined;
        __from_save = undefined;

        start_out();
    }
}

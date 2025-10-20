/// @func script_transition_goto(room_target, spawn_tag)
function script_transition_goto(room_target, spawn_tag)
{
    // Hard guard: if a transition is already running, do nothing.
    if (variable_global_exists("_transition_busy") && global._transition_busy) {
        // show_debug_message("[transition] ignored: busy");
        return;
    }

    var _layer_name;
    if (layer_exists("FX"))          _layer_name = "FX";
    else if (layer_exists("actors")) _layer_name = "actors";
    else                             _layer_name = layer_get_name(layer_first());

    if (!instance_exists(oMirrorTransition)) {
        instance_create_layer(0, 0, _layer_name, oMirrorTransition);
    }

    var __target_room  = room_target;
    var __target_spawn = spawn_tag;
    var __use_mirror   = (room == SaveRoom) || (room_target == SaveRoom);

    with (oMirrorTransition) {
        target_room  = __target_room;
        target_spawn = __target_spawn;
        use_mirror   = __use_mirror;
        start_out(); // this will set global._transition_busy = true
    }
}



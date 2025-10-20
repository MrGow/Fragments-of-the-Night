/// @func script_transition_goto(room_target_or_struct, spawn_tag)
/// @desc Start a transition to a room. Accepts either a Room asset,
///       or a struct/instance that has a room field: room_target / target_room / target.
function script_transition_goto(room_target_or_struct, spawn_tag)
{
    // Refuse while busy
    if (variable_global_exists("_transition_busy") && global._transition_busy) return;

    // --- Resolve a proper room asset WITHOUT using instance_* APIs (avoids GM1041) ---
    var _room = undefined;

    // If caller gave us a struct (instances are structs), read a room field from it.
    if (is_struct(room_target_or_struct)) {
        if (variable_struct_exists(room_target_or_struct, "room_target"))  _room = room_target_or_struct.room_target;
        else if (variable_struct_exists(room_target_or_struct, "target_room")) _room = room_target_or_struct.target_room;
        else if (variable_struct_exists(room_target_or_struct, "target"))      _room = room_target_or_struct.target;
        else _room = undefined;
    } else {
        // Assume they passed a room asset directly
        _room = room_target_or_struct;
    }

    // Final validation
    if (!room_exists(_room)) {
        show_debug_message("[transition] ERROR: invalid room passed to script_transition_goto: " + string(_room));
        return;
    }

    // Pick a safe layer
    var _layer_name;
    if (layer_exists("FX"))          _layer_name = "FX";
    else if (layer_exists("actors")) _layer_name = "actors";
    else                             _layer_name = layer_get_name(layer_first());

    if (!instance_exists(oMirrorTransition)) {
        instance_create_layer(0, 0, _layer_name, oMirrorTransition);
    }

    var __target_room  = _room;
    var __target_spawn = spawn_tag;
    var __use_mirror   = (room == SaveRoom) || (__target_room == SaveRoom);

    with (oMirrorTransition) {
        target_room  = __target_room;
        target_spawn = __target_spawn;
        use_mirror   = __use_mirror;
        start_out();
    }
}




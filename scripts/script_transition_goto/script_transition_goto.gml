/// script_transition_goto(room_or_name, spawn_tag)
// Modern function version (no deprecated argument[]; safe across GM updates)

function script_transition_goto(_room, _spawn_tag) {
    // Resolve room if a string name is passed
    if (is_string(_room)) {
        var rid = asset_get_index(_room);
        if (rid != -1) _room = rid;
    }

    if (is_undefined(_spawn_tag)) _spawn_tag = "default";

    // If a transition is already running, ignore the request
    if (variable_global_exists("_transition_busy") && global._transition_busy) return;

    // Direction hint for the mirror transition (optional)
    var _to_save = (_room == SaveRoom);

    // Get (or create) the transition singleton
    var tr = noone;
    if (instance_exists(oMirrorTransition)) {
        tr = instance_find(oMirrorTransition, 0);
    } else {
        var _layer_name = "";
        if (layer_exists("FX"))          _layer_name = "FX";
        else if (layer_exists("actors")) _layer_name = "actors";

        tr = (_layer_name != "")
           ? instance_create_layer(0, 0, _layer_name, oMirrorTransition)
           : instance_create_depth(0, 0, -16000, oMirrorTransition);
    }

    if (tr == noone) {
        show_debug_message("[transition_goto] FAILED to create oMirrorTransition");
        return;
    }

    // Optional: give the camera a brief guard to prevent flicker on handover
    if (object_exists(oCamera) && instance_exists(oCamera)) {
        with (oCamera) transition_guard = max(transition_guard, 8);
    }

    // Set up transition data (the transition object will drive the effect)
    with (tr) {
        target_room     = _room;
        target_spawn    = _spawn_tag;
        play_mode       = _to_save ? PlayMode.ForwardOnly : PlayMode.ReverseOnly;
        start_requested = true;
    }
}

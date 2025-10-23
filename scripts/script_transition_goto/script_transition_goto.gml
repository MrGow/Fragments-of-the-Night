/// script_transition_goto(_target_room, _spawn_tag)
/// @param _target_room
/// @param _spawn_tag

var _target_room = argument0;
var _spawn_tag   = argument1;

// If a transition is running, ignore
if (variable_global_exists("_transition_busy") && global._transition_busy) exit;

// Direction: TO SaveRoom = forward shatter; FROM SaveRoom = reverse rebuild
var _to_save = (_target_room == SaveRoom);

// Get (or create) the singleton
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

// Bail if creation failed
if (tr == noone) {
    show_debug_message("[transition_goto] FAILED to create oMirrorTransition");
    exit;
}

// Configure only — no function calls, no sprite reads
with (tr) {
    target_room   = _target_room;
    target_spawn  = _spawn_tag;
    play_mode     = _to_save ? PlayMode.ForwardOnly : PlayMode.ReverseOnly;
    start_requested = true; // the instance will kick off in its own Step
}

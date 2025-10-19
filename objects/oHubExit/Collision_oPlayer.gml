/// oHubExit — Collision with oPlayer  (NO LOCKING)

// Require UP to leave? (toggle as desired)
var require_up = true;
if (require_up) {
    var pressed_up = keyboard_check_pressed(vk_up) || keyboard_check_pressed(ord("W"));
    for (var dev = 0; dev < 8; dev++) {
        if (!gamepad_is_connected(dev)) continue;
        if (gamepad_button_check_pressed(dev, gp_padu)) pressed_up = true;
    }
    if (!pressed_up) exit;
}

// Prepare return spawn (use the tag we saved when entering via oCamDoor)
if (!is_undefined(global.return_spawn_id)) {
    global.spawn_tag_next = string(global.return_spawn_id);
}

var target = is_undefined(global.return_room) ? room : global.return_room;

// Start transition (no locks, no flags)
if (object_exists(oFade)) {
    var _layer = layer_get_id("Actors");
    if (_layer == -1) _layer = layer_get_id("FX");
    if (_layer == -1) _layer = layer_create(0, "Actors");
    var f = instance_exists(oFade) ? instance_find(oFade, 0)
                                   : instance_create_layer(0, 0, _layer, oFade);
    with (f) {
        target_room    = target;
        pending_switch = true;
        if (state == 0) { state = 1; transit_ttl = 12; }
    }
} else {
    room_goto(target);
}

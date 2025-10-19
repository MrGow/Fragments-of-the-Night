/// oHubExit - Step
var pl = instance_nearest(x, y, oPlayer);
var hovering = (pl != noone) && place_meeting(x, y, oPlayer);

function _pressed_up() {
    if (keyboard_check_pressed(vk_up) || keyboard_check(vk_up)) return true;
    for (var dev = 0; dev < 8; dev++) {
        if (!gamepad_is_connected(dev)) continue;
        if (gamepad_button_check_pressed(dev, gp_padu)) return true;
    }
    return false;
}

if (hovering && _pressed_up()) {
    // Prepare return spawn
    global.spawn_tag_next = string(global.return_spawn_id);

    // Trigger fade to the last combat room
    var _layer = layer_get_id("Actors");
    if (_layer == -1) _layer = layer_get_id("FX");
    if (_layer == -1) _layer = layer_create(0, "Actors");

    var f = instance_exists(oFade) ? instance_find(oFade, 0)
                                   : instance_create_layer(0, 0, _layer, oFade);

    with (f) {
        target_room    = global.return_room;
        pending_switch = true;
        if (state == 0) { state = 1; transit_ttl = 12; }
    }
}

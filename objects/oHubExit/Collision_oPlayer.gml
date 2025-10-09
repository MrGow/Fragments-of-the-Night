if (!up_pressed()) exit;

// ROOM-TYPED return target saved earlier by the mirror door
if (!variable_global_exists("return_room")) exit;
var r_target = global.return_room;

// tell the NEXT room where to place the player (always set it!)
var tag = (variable_global_exists("return_spawn_id") && !is_undefined(global.return_spawn_id))
          ? global.return_spawn_id
          : "mirror_exit_back";
global.spawn_tag_next = tag;

// fade to the return room
var f = instance_exists(oFade) ? instance_find(oFade, 0)
                               : instance_create_layer(0, 0, "Instances", oFade);
with (f) {
    target_room    = r_target;   // ROOM asset, not a string/index
    pending_switch = true;
    if (state == 0) { state = 1; transit_ttl = 12; }
}
